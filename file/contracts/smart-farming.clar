;; smart-farming.clar
;; Main contract for Smart Farming IoT System

(define-data-var contract-owner principal tx-sender)
(define-map authorized-sensors principal bool)
(define-map sensor-data
    {sensor-id: uint, timestamp: uint}
    {temperature: int, moisture: uint, health-index: uint}
)

(define-public (register-sensor (sensor-principal principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
        (ok (map-set authorized-sensors sensor-principal true))
    )
)

(define-public (record-sensor-data 
    (sensor-id uint)
    (temperature int)
    (moisture uint)
    (health-index uint)
)
    (let
        (
            (timestamp block-height)
        )
        (asserts! (default-to false (map-get? authorized-sensors tx-sender)) (err u2))
        (ok (map-set sensor-data
            {sensor-id: sensor-id, timestamp: timestamp}
            {temperature: temperature, moisture: moisture, health-index: health-index}
        ))
    )
)

;; sensors-registry.clar
;; Sensor management contract

(define-map sensor-details
    principal
    {
        sensor-type: (string-utf8 32),
        location: (string-utf8 64),
        installation-date: uint,
        last-maintenance: uint
    }
)

(define-public (register-sensor-details
    (sensor-principal principal)
    (sensor-type (string-utf8 32))
    (location (string-utf8 64))
)
    (let
        (
            (timestamp block-height)
        )
        (ok (map-set sensor-details
            sensor-principal
            {
                sensor-type: sensor-type,
                location: location,
                installation-date: timestamp,
                last-maintenance: timestamp
            }
        ))
    )
)

;; data-storage.clar
;; Data storage and retrieval contract

(define-map historical-data
    uint
    {
        sensor-id: uint,
        temperature: int,
        moisture: uint,
        health-index: uint,
        timestamp: uint
    }
)

(define-data-var data-counter uint u0)

(define-public (store-historical-data
    (sensor-id uint)
    (temperature int)
    (moisture uint)
    (health-index uint)
)
    (let
        (
            (counter (var-get data-counter))
            (timestamp block-height)
        )
        (var-set data-counter (+ counter u1))
        (ok (map-set historical-data
            counter
            {
                sensor-id: sensor-id,
                temperature: temperature,
                moisture: moisture,
                health-index: health-index,
                timestamp: timestamp
            }
        ))
    )
)
