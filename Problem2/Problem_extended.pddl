(define (problem sample_collection_extended)
    (:domain sample_collection)

    (:objects
        Base SiteA SiteB SiteC SiteD SiteE SiteF - area
        Bay1 Bay2 - storage
        Curiosity - rover
        Drill1 - drill
        Rock1 Rock2 Rock4 Rock6 - soft
        Rock3 Rock5 Rock7 - hard
    )

    (:init
        (CONNECTED Base SiteA)
        (CONNECTED SiteA Base)
        (CONNECTED SiteA SiteC)
        (CONNECTED SiteC SiteA)
        (CONNECTED SiteB SiteD)
        (CONNECTED SiteD SiteB)
        (CONNECTED SiteC SiteE)
        (CONNECTED SiteE SiteC)
        (CONNECTED SiteD SiteE)
        (CONNECTED SiteE SiteD)
        (CONNECTED SiteE SiteF)
        (CONNECTED SiteF SiteE)
        (CONNECTED SiteC SiteD)

        (rover-at-area Curiosity Base)

        (storage-empty Curiosity Bay1)
        (storage-empty Curiosity Bay2)

        (drill-at-area Drill1 SiteE)

        (rock-at-area Rock1 SiteA)
        (rock-at-area Rock2 SiteB)
        (rock-at-area Rock3 SiteC)
        (rock-at-area Rock4 SiteD)
        (rock-at-area Rock5 SiteF)
        (rock-at-area Rock6 SiteE)
        (rock-at-area Rock7 SiteF)
    )

    (:goal
        (and
            (rock-at-area Rock1 Base)
            (rock-at-area Rock2 Base)
            (rock-at-area Rock3 Base)
            (rock-at-area Rock4 Base)
            (rock-at-area Rock5 Base)
            (rock-at-area Rock6 Base)
            (rock-at-area Rock7 Base)
            (storage-empty Curiosity Bay1)
            (storage-empty Curiosity Bay2)
            (rover-at-area Curiosity Base)
        )
    )
)
