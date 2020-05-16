#!/bin/bash

NAME_MACHINE="HP16"
NUM_IMAGE_PER_GPU=64
MONITOR_INTERVAL=1
DIR_A="data/faces/trump"
DIR_B="data/faces/fauci"
DIR_M="model_benchmark"
DIR_ala="data/src/trump/trump_alignments.fsa"
DIR_alb="data/src/fauci/fauci_alignments.fsa"
NUM_ITER=50
MODEL_NAME="dfl-h128"

mkdir -p "benchmark/"${NAME_MACHINE}"_"${MODEL_NAME}

benchmark() {
	local bs="$1"
	local num_gpu="$2"
	local data_syn="$3"
	local output_file="$4"
	local gpu_monitor_file="$5"


	params=()
	params+=("--batch-size="${bs})
	params+=("--gpus="${num_gpu})
	[[ $data_syn == "syn" ]] && params+=("-data_syn")
	params+=("--input-A="${DIR_A})
	params+=("--input-B="${DIR_B})
	params+=("--alignments-A="${DIR_ala})
	params+=("--alignments-B="${DIR_alb})
	params+=("--model-dir="${DIR_M})
	params+=("--iterations="${NUM_ITER})

	echo "${params[@]}"
	rm -rf $DIR_M

	flag_monitor=true

	while $flag_monitor;
	do
		last_line="$(tail -1 $output_file)"
		if [ "$last_line" == "Job finished" ]; then
			flag_monitor=false
		else
			status="$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used --format=csv)"
			echo "${status}" >> $gpu_monitor_file
		fi
		sleep $MONITOR_INTERVAL
	done & python faceswap.py train \
	"${params[@]}" \
	-nac -nf -L DEBUG -t $MODEL_NAME > $output_file 

}


for num_gpu in 16
do
	bs=$((NUM_IMAGE_PER_GPU*num_gpu))
	
	## Train with real data
	#output_file="benchmark/"${NAME_MACHINE}"_"${MODEL_NAME}"/"${NAME_MACHINE}"_gpu_"${num_gpu}"_bs_"${bs}"_real.txt"
	#gpu_monitor_file="benchmark/"${NAME_MACHINE}"_"${MODEL_NAME}"/"${NAME_MACHINE}"_gpu_"${num_gpu}"_bs_"${bs}"_real_monitor.csv"
	#
	#benchmark $bs $num_gpu "real" $output_file $gpu_monitor_file

	# Train with syn data
	output_file="benchmark/"${NAME_MACHINE}"_"${MODEL_NAME}"/"${NAME_MACHINE}"_gpu_"${num_gpu}"_bs_"${bs}"_syn.txt"
	gpu_monitor_file="benchmark/"${NAME_MACHINE}"_"${MODEL_NAME}"/"${NAME_MACHINE}"_gpu_"${num_gpu}"_bs_"${bs}"_syn_monitor.csv"

	benchmark $bs $num_gpu "syn" $output_file $gpu_monitor_file
done
