(define (problem rover-mission)
  (:domain mars-rover)

  (:objects
    curiosity - rover
    base siteA siteB siteC siteD siteE siteF - location
    rock1 rock2 rock3 rock4 rock5 - rock
    bay1 bay2 - bay
    drill1 - drill
  )

  (:init
    (rover-at curiosity base)
    (bay-of bay1 curiosity) (bay-of bay2 curiosity)
    (bay-empty bay1) (bay-empty bay2)

    (drill-at drill1 siteE)

    (rock-at rock1 siteA) (soft rock1)
    (rock-at rock2 siteB) (soft rock2)
    (rock-at rock3 siteC) (hard rock3)
    (rock-at rock4 siteD) (soft rock4)
    (rock-at rock5 siteF) (hard rock5)

    ; two-way routes
    (path base siteA)  (path siteA base)
    (path base siteB)  (path siteB base)
    (path siteA siteC) (path siteC siteA)
    (path siteB siteD) (path siteD siteB)
    (path siteC siteE) (path siteE siteC)
    (path siteD siteE) (path siteE siteD)
    (path siteE siteF) (path siteF siteE)
    ; steep slope, downhill only
    (path siteC siteD)
  )

  (:goal (and
    (rock-at rock1 base) (rock-at rock2 base) (rock-at rock3 base)
    (rock-at rock4 base) (rock-at rock5 base)
    (bay-empty bay1) (bay-empty bay2)
    (rover-at curiosity base)
  ))
)
