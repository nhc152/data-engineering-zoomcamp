# Broken Scenario 01 - Dashboard Scans Raw Events Every Minute

## Symptom

Cloud bill spikes. BigQuery job history shows a BI service account running the same raw events query every minute.

## Root Cause

Dashboard queries raw events directly:

- no aggregate mart
- high refresh frequency
- scans many columns/partitions

## Evidence To Collect

- job history by user/service account
- bytes scanned per query
- dashboard refresh schedule
- query text
- table scanned

## Why It Is Bad

Serving queries should be cheap and predictable. Raw event scans are usually not.

## Expected Fix

Create a daily/hourly aggregate mart and point dashboard to the mart.

