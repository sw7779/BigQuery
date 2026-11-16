CREATE OR REPLACE MODEL `bdaa-occ2-g6.readmissions_data.readmission_prediction_xgb_model`
OPTIONS(
  model_type='BOOSTED_TREE_CLASSIFIER',
  input_label_cols=['readmitted'],
  data_split_method='AUTO_SPLIT'
) AS
SELECT
  readmitted,
  age_encoded,
  time_in_hospital_scaled,
  n_lab_procedures_scaled,
  n_procedures_scaled,
  n_medications_scaled,
  n_outpatient_scaled,
  n_inpatient_scaled,
  n_emergency_scaled,
  change_encoded,
  diabetes_med_encoded,
  glucose_test_normal,
  glucose_test_high,
  A1Ctest_normal,
  A1Ctest_high
FROM `bdaa-occ2-g6.readmissions_data.readmissions_cleaned`;  -- Use cleaned dataset

#Evaluate XGB
SELECT 
  *
FROM 
  ML.EVALUATE(MODEL `bdaa-occ2-g6.readmissions_data.readmission_prediction_xgb_model`,
    (SELECT
      readmitted,
      age_encoded,
      time_in_hospital_scaled,
      n_lab_procedures_scaled,
      n_procedures_scaled,
      n_medications_scaled,
      n_outpatient_scaled,
      n_inpatient_scaled,
      n_emergency_scaled,
      change_encoded,
      diabetes_med_encoded,
      glucose_test_normal,
      glucose_test_high,
      A1Ctest_normal,
      A1Ctest_high
    FROM `bdaa-occ2-g6.readmissions_data.readmissions_cleaned`
    WHERE readmitted IS NOT NULL));  -- Evaluate on the test set (exclude rows with NULL target values)
