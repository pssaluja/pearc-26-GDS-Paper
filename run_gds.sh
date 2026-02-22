#!/bin/bash

BASEDIR="/users/psaluja/6_PEARC"
OUTPUT="$BASEDIR/gds_results_v2.txt"
GPFS_PATH="/jobtmp/psaluja/gds_tmp"
VAST_PATH="/oscar/scratch/psaluja/gds_tmp"
GDSIO="/usr/local/cuda-13.1/gds/tools/gdsio"
DURATION=120
COOLDOWN=30

run_test() {
    local label="$1"
    local args="$2"
    echo "==============================" >> $OUTPUT
    echo "TEST: $label" >> $OUTPUT
    echo "CMD: $GDSIO $args" >> $OUTPUT
    date >> $OUTPUT
    $GDSIO $args >> $OUTPUT 2>&1
    date >> $OUTPUT
    echo "" >> $OUTPUT
    echo "Cooling down ${COOLDOWN}s..." >> $OUTPUT
    sync
    sleep $COOLDOWN
}

echo "GDS Benchmark Results v2" > $OUTPUT
echo "Run: $(date)" >> $OUTPUT
echo "" >> $OUTPUT

for BS in 256K 512K 1M 2M 4M 8M 16M; do

    # ── GPFS ──
    run_test "GPFS | Non-GDS Write | $BS" \
        "-D $GPFS_PATH -d 0 -w 8 -s 500M -i $BS -x 1 -I 1 -T $DURATION"
    run_test "GPFS | Non-GDS Read  | $BS" \
        "-D $GPFS_PATH -d 0 -w 8 -s 500M -i $BS -x 1 -I 0 -T $DURATION"
    run_test "GPFS | GDS Write     | $BS" \
        "-D $GPFS_PATH -d 0 -w 8 -s 500M -i $BS -x 0 -I 1 -T $DURATION"
    run_test "GPFS | GDS Read      | $BS" \
        "-D $GPFS_PATH -d 0 -w 8 -s 500M -i $BS -x 0 -I 0 -T $DURATION"

    # ── VAST ──
    run_test "VAST | Non-GDS Write | $BS" \
        "-D $VAST_PATH -d 0 -w 8 -s 500M -i $BS -x 1 -I 1 -T $DURATION"
    run_test "VAST | Non-GDS Read  | $BS" \
        "-D $VAST_PATH -d 0 -w 8 -s 500M -i $BS -x 1 -I 0 -T $DURATION"
    run_test "VAST | GDS Write     | $BS" \
        "-D $VAST_PATH -d 0 -w 8 -s 500M -i $BS -x 0 -I 1 -T $DURATION"
    run_test "VAST | GDS Read      | $BS" \
        "-D $VAST_PATH -d 0 -w 8 -s 500M -i $BS -x 0 -I 0 -T $DURATION"

done

echo "==============================" >> $OUTPUT
echo "All done: $(date)" >> $OUTPUT