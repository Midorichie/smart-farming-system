;; data-storage.clar
;; Data storage and retrieval contract for Smart Farming IoT System

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

(define-map aggregated-data
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
(define-data-var storage-admin principal tx-sender)

;; Data Storage Functions
(define-public (store-reading
    (sensor principal)
    (temperature int)
    (moisture uint)
    (health-index uint)
    (reading-type (string-utf8 32))
)
    (let
        (
            (reading-id (var-get reading-counter))
            (current-date (/ block-height u144))  ;; Approximate daily blocks
        )
        (begin
            (asserts! (is-authorized sensor) (err u403))
            (var-set reading-counter (+ reading-id u1))
            (map-set sensor-readings
                reading-id
                {
                    sensor: sensor,
                    temperature: temperature,
                    moisture: moisture,
                    health-index: health-index,
                    timestamp: block-height,
                    reading-type: reading-type
                }
            )
            (update-aggregated-data sensor temperature moisture health-index current-date)
            (ok reading-id)
        )
    )
)

;; Aggregation Helper Function
(define-private (update-aggregated-data
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
            (map-get? aggregated-data {sensor: sensor, date: date})
        )))
        (ok (map-set aggregated-data
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

;; Query Functions
(define-read-only (get-reading (reading-id uint))
    (map-get? sensor-readings reading-id)
)

(define-read-only (get-daily-aggregates
    (sensor principal)
    (date uint)
)
    (map-get? aggregated-data {sensor: sensor, date: date})
)

;; Authorization Helper
(define-private (is-authorized (sensor principal))
    (is-some (map-get? sensor-registry sensor))
)
