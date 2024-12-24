;; smart-farming.clar
;; Main contract for Smart Farming IoT System

(define-data-var contract-owner principal tx-sender)
(define-map authorized-sensors principal bool)
(define-map sensor-data
    {sensor-id: uint, timestamp: uint}
    {temperature: int, moisture: uint, health-index: uint}
)

;; Authorization check
(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner))
)

(define-public (register-sensor (sensor-principal principal))
    (begin
        (asserts! (is-contract-owner) (err u1))
        (ok (map-set authorized-sensors sensor-principal true))
    )
)

(define-read-only (get-sensor-authorization (sensor principal))
    (default-to false (map-get? authorized-sensors sensor))
)

(define-map sensor-readings
    uint  ;; reading-id
    {
        sensor: principal,
        temperature: int,
        moisture: uint,
        health-index: uint,
        timestamp: uint,
        reading-type: (string-utf8 32)
    }
)

(define-map daily-aggregates
    {sensor: principal, date: uint}
    {
        avg-temperature: int,
        avg-moisture: uint,
        avg-health-index: uint,
        reading-count: uint,
        min-temperature: int,
        max-temperature: int,
        min-moisture: uint,
        max-moisture: uint
    }
)

(define-data-var reading-counter uint u0)

(define-private (update-daily-aggregates
    (sensor principal)
    (temperature int)
    (moisture uint)
    (health-index uint)
    (date uint)
)
    (let
        ((current-data (default-to
            {
                avg-temperature: temperature,
                avg-moisture: moisture,
                avg-health-index: health-index,
                reading-count: u1,
                min-temperature: temperature,
                max-temperature: temperature,
                min-moisture: moisture,
                max-moisture: moisture
            }
            (map-get? daily-aggregates {sensor: sensor, date: date})
        )))
        (ok (map-set daily-aggregates
            {sensor: sensor, date: date}
            {
                avg-temperature: (/ (+ (* (get avg-temperature current-data) (to-int (get reading-count current-data))) temperature) (to-int (+ (get reading-count current-data) u1))),
                avg-moisture: (/ (+ (* (get avg-moisture current-data) (get reading-count current-data)) moisture) (+ (get reading-count current-data) u1)),
                avg-health-index: (/ (+ (* (get avg-health-index current-data) (get reading-count current-data)) health-index) (+ (get reading-count current-data) u1)),
                reading-count: (+ (get reading-count current-data) u1),
                min-temperature: (if (< temperature (get min-temperature current-data)) temperature (get min-temperature current-data)),
                max-temperature: (if (> temperature (get max-temperature current-data)) temperature (get max-temperature current-data)),
                min-moisture: (if (< moisture (get min-moisture current-data)) moisture (get min-moisture current-data)),
                max-moisture: (if (> moisture (get max-moisture current-data)) moisture (get max-moisture current-data))
            }
        ))
    )
)

(define-public (record-sensor-data 
    (sensor-id uint)
    (temperature int)
    (moisture uint)
    (health-index uint)
    (reading-type (string-utf8 32))
)
    (let
        (
            (timestamp block-height)
            (reading-id (var-get reading-counter))
            (current-date (/ block-height u144))  ;; Approximate daily blocks
        )
        (begin
            (asserts! (get-sensor-authorization tx-sender) (err u2))
            (unwrap! (update-daily-aggregates tx-sender temperature moisture health-index current-date) (err u500))
            (var-set reading-counter (+ reading-id u1))
            (ok (map-set sensor-readings
                reading-id
                {
                    sensor: tx-sender,
                    temperature: temperature,
                    moisture: moisture,
                    health-index: health-index,
                    timestamp: block-height,
                    reading-type: reading-type
                }
            ))
        )
    )
)

;; Query functions
(define-read-only (get-reading (reading-id uint))
    (map-get? sensor-readings reading-id)
)

(define-read-only (get-daily-aggregate (sensor principal) (date uint))
    (map-get? daily-aggregates {sensor: sensor, date: date})
)
