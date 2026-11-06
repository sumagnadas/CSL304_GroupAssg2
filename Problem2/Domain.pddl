(define (domain sample_collection)

    (:requirements
        :strips
        :typing
    )

    (:types
        rover rock location drill - object
        soft hard - rock
        area storage - location
    )
    (:predicates 
        (CONNECTED ?a - area ?b - area)   ; connection between places
        (storage-filled ?r - rover ?s - storage) (storage-empty ?r - rover ?s - storage)
        (has-drill ?r - rover ?d - drill)  ; ROBOT STATES
        (rover-at-area ?r - rover ?a - area) (rock-at-area ?x - rock ?l - location) ; LOCATION STATES
        (drill-at-area ?d - drill ?a - area)                                        ; LOCATION STATES 2
    )

    (:action move :parameters (?r - rover ?a - area ?b - area)
        :precondition (and (rover-at-area ?r ?a) (CONNECTED ?a ?b))
        :effect       (and (rover-at-area ?r ?b) (not (rover-at-area ?r ?a)))
    )
    (:action pick-drill :parameters (?r - rover ?a - area ?d - drill)
        :precondition (and (rover-at-area ?r ?a) (drill-at-area ?d ?a)) 
        :effect       (and (has-drill ?r ?d) (not (drill-at-area ?d ?a)))
    )
    (:action collect-soft :parameters (?r - rover ?a - area ?x - soft ?s - storage)
        :precondition (and (rover-at-area ?r ?a) (storage-empty ?r ?s) (rock-at-area ?x ?a)) 
        :effect       (and (storage-filled ?r ?s) (rock-at-area ?x ?s) (not (rock-at-area ?x ?a)) (not (storage-empty ?r ?s)))
    )
    (:action collect-hard :parameters (?r - rover ?a - area ?x - hard ?s - storage ?d - drill)
        :precondition (and (rover-at-area ?r ?a) (storage-empty ?r ?s) (rock-at-area ?x ?a) (has-drill ?r ?d)) 
        :effect       (and (storage-filled ?r ?s) (rock-at-area ?x ?s) (not (rock-at-area ?x ?a)) (not (storage-empty ?r ?s)))
    )
    (:action deposit :parameters (?r - rover ?a - area ?x - rock ?s - storage)
        :precondition (and (rover-at-area ?r ?a) (storage-filled ?r ?s) (rock-at-area ?x ?s)) 
        :effect       (and (not (storage-filled ?r ?s)) (rock-at-area ?x ?a) (not (rock-at-area ?x ?s)) (storage-empty ?r ?s))
    )
)