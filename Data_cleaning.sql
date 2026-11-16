#Data Cleaning
CREATE OR REPLACE TABLE 
  -- Target Table: bdaa-occ2-g6.readmissions_data.readmissions_cleaned
  `bdaa-occ2-g6.readmissions_data.readmissions_cleaned`
AS
WITH stats AS (
  -- Calculate mean and standard deviation for scaling
  SELECT
    AVG(time_in_hospital) AS avg_time_in_hospital,
    STDDEV(time_in_hospital) AS stddev_time_in_hospital,
    AVG(n_lab_procedures) AS avg_n_lab_procedures,
    STDDEV(n_lab_procedures) AS stddev_n_lab_procedures,
    AVG(n_procedures) AS avg_n_procedures,
    STDDEV(n_procedures) AS stddev_n_procedures,
    AVG(n_medications) AS avg_n_medications,
    STDDEV(n_medications) AS stddev_n_medications,
    AVG(n_outpatient) AS avg_n_outpatient,
    STDDEV(n_outpatient) AS stddev_n_outpatient,
    AVG(n_inpatient) AS avg_n_inpatient,
    STDDEV(n_inpatient) AS stddev_n_inpatient,
    AVG(n_emergency) AS avg_n_emergency,
    STDDEV(n_emergency) AS stddev_n_emergency
  FROM `bdaa-occ2-g6.readmissions_data.readmissions_table`
)

SELECT
    -- 1. Target Variable (readmitted): Binary Encoding
    CASE WHEN t.readmitted = TRUE THEN 1 ELSE 0 END AS readmitted,

    -- 2. Ordinal Encoding for 'age' (age ranges converted to numeric)
    CASE
      WHEN t.age = '[40-50)' THEN 1
      WHEN t.age = '[50-60)' THEN 2
      WHEN t.age = '[60-70)' THEN 3
      WHEN t.age = '[70-80)' THEN 4
      WHEN t.age = '[80-90)' THEN 5
      WHEN t.age = '[90-100)' THEN 6
      ELSE NULL
    END AS age_encoded,

    -- 3. Numerical Features (Scaling using StandardScaler)
    (t.time_in_hospital - s.avg_time_in_hospital) / s.stddev_time_in_hospital AS time_in_hospital_scaled,
    (t.n_lab_procedures - s.avg_n_lab_procedures) / s.stddev_n_lab_procedures AS n_lab_procedures_scaled,
    (t.n_procedures - s.avg_n_procedures) / s.stddev_n_procedures AS n_procedures_scaled,
    (t.n_medications - s.avg_n_medications) / s.stddev_n_medications AS n_medications_scaled,
    (t.n_outpatient - s.avg_n_outpatient) / s.stddev_n_outpatient AS n_outpatient_scaled,
    (t.n_inpatient - s.avg_n_inpatient) / s.stddev_n_inpatient AS n_inpatient_scaled,
    (t.n_emergency - s.avg_n_emergency) / s.stddev_n_emergency AS n_emergency_scaled,

    -- 4. Binary Encoding for 'change', 'diabetes_med' (Boolean Encoding)
    CASE WHEN t.change = TRUE THEN 1 ELSE 0 END AS change_encoded,
    CASE WHEN t.diabetes_med = TRUE THEN 1 ELSE 0 END AS diabetes_med_encoded,

    -- 5. One-Hot Encoding for 'glucose_test' (Nominal Encoding)
    CASE WHEN t.glucose_test = 'normal' THEN 1 ELSE 0 END AS glucose_test_normal,
    CASE WHEN t.glucose_test = 'high' THEN 1 ELSE 0 END AS glucose_test_high,

    -- 6. One-Hot Encoding for 'A1Ctest' (Nominal Encoding)
    CASE WHEN t.A1Ctest = 'normal' THEN 1 ELSE 0 END AS A1Ctest_normal,
    CASE WHEN t.A1Ctest = 'high' THEN 1 ELSE 0 END AS A1Ctest_high,

FROM
  -- Source Table (Raw Data): bdaa-occ2-g6.readmissions_data.readmissions_table
  `bdaa-occ2-g6.readmissions_data.readmissions_table` AS t
JOIN stats s ON TRUE;  
