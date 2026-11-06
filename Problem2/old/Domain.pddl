; Mars rover sample collection - domain
; only :strips and :typing are used, so soft/hard and empty/full are separate positive facts

(define (domain mars-rover)
  (:requirements :strips :typing)

  (:types
    rover location rock bay drill - object
  )

  (:predicates
    (rover-at ?r - rover ?l - location)
    (rock-at ?k - rock ?l - location)
    (drill-at ?d - drill ?l - location)
    (path ?from - location ?to - location)     ; one direction only, two-way routes get two facts
    (bay-of ?b - bay ?r - rover)
    (bay-empty ?b - bay)
    (in-bay ?k - rock ?b - bay)
    (soft ?k - rock)
    (hard ?k - rock)
    (has-drill ?r - rover)
  )

  (:action move
    :parameters (?r - rover ?from - location ?to - location)
    :precondition (and (rover-at ?r ?from) (path ?from ?to))
    :effect (and (rover-at ?r ?to) (not (rover-at ?r ?from)))
  )

  (:action pick-drill
    :parameters (?r - rover ?d - drill ?l - location)
    :precondition (and (rover-at ?r ?l) (drill-at ?d ?l))
    :effect (and (has-drill ?r) (not (drill-at ?d ?l)))
  )

  (:action collect-soft
    :parameters (?r - rover ?k - rock ?b - bay ?l - location)
    :precondition (and (rover-at ?r ?l) (rock-at ?k ?l) (soft ?k)
                       (bay-of ?b ?r) (bay-empty ?b))
    :effect (and (in-bay ?k ?b) (not (rock-at ?k ?l)) (not (bay-empty ?b)))
  )

  (:action collect-hard
    :parameters (?r - rover ?k - rock ?b - bay ?l - location)
    :precondition (and (rover-at ?r ?l) (rock-at ?k ?l) (hard ?k) (has-drill ?r)
                       (bay-of ?b ?r) (bay-empty ?b))
    :effect (and (in-bay ?k ?b) (not (rock-at ?k ?l)) (not (bay-empty ?b)))
  )

  (:action deposit
    :parameters (?r - rover ?k - rock ?b - bay ?l - location)
    :precondition (and (rover-at ?r ?l) (in-bay ?k ?b) (bay-of ?b ?r))
    :effect (and (rock-at ?k ?l) (bay-empty ?b) (not (in-bay ?k ?b)))
  )
)
