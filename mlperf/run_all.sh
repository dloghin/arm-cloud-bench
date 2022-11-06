#!/bin/bash

TSTP=`date +%F-%H-%M-%S`
LOGD="logs-mlperf-$TSTP"
mkdir $LOGD
LOGD=`pwd`/$LOGD

REPS=3

cd /tmp/inference/vision/classification_and_detection
export DATA_DIR=/data/coco-300

for REP in `seq 1 $REPS`; do
	export MODEL_DIR=/data/models/tf_ssd_mobilenet
	./run_local.sh tf ssd-mobilenet cpu 2>&1 | tee $LOGD/tf-log-$REP.txt
	export MODEL_DIR=/data/models/pytorch_ssd_mobilenet
	./run_local.sh pytorch ssd-mobilenet cpu 2>&1 | tee $LOGD/pytorch-log-$REP.txt
	export MODEL_DIR=/data/models/onnx_ssd_mobilenet
	./run_local.sh onnxruntime ssd-mobilenet cpu 2>&1 | tee $LOGD/onnx-log-$REP.txt
done
