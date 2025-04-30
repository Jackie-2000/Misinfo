PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
export REPO_HOME="${PROJECT_ROOT}"
echo "REPO_HOME: $REPO_HOME"
# on remote
data_paths="/data3/qianqi/code/Misinfo/VLM-R1/train.jsonl:/data3/qianqi/code/Misinfo/VLM-R1/val.jsonl"
image_folders="/data3/qianqi/dataset/visual_news/origin:/data3/qianqi/dataset/visual_news/origin"
model_path="/data2/qianqi/model_weights/Qwen2.5-VL-3B-Instruct"
is_reward_customized_from_vlm_module=False
echo "data_paths: $data_paths"
echo "image_folders: $image_folders"

export EXP_NAME="bs_8_ng_4_lora_Qwen2.5-VL-3B-Instruct" # TODO: change this to your own experiment name
TASK_TYPE="custom"
cd ${REPO_HOME}/src/open-r1-multimodal

export DEBUG_MODE="true" # Enable Debug if you want to see the rollout of model during RL
# create the run directory and log file
mkdir -p ${REPO_HOME}/runs/${EXP_NAME}/log
export LOG_PATH="${REPO_HOME}/runs/${EXP_NAME}/log/debug_log.$(date +%Y-%m-%d-%H-%M-%S).txt"
# MAX_STEPS=1200 # TODO: change this to your own max steps


# export WANDB_DISABLED=true
# CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6
PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node="4" \
    --nnodes="1" \
    --node_rank="0" \
    --master_addr="127.0.0.1" \
    --master_port="12349" \
  src/open_r1/grpo_misinfo.py \
    --use_vllm False \
    --output_dir ${REPO_HOME}/checkpoints/rl/${EXP_NAME} \
    --resume_from_checkpoint True \
    --model_name_or_path $model_path \
    --data_file_paths $data_paths \
    --image_folders $image_folders \
    --is_reward_customized_from_vlm_module $is_reward_customized_from_vlm_module \
    --task_type $TASK_TYPE \
    --per_device_train_batch_size 8 \
    --gradient_accumulation_steps 2 \
    --gradient_checkpointing true \
    --logging_steps 1 \
    --num_train_epochs 1 \
    --bf16 \
    --attn_implementation flash_attention_2 \
    --run_name ${EXP_NAME} \
    --data_seed 42 \
    --save_steps 100 \
    --num_generations 4 \
    --max_completion_length 1024 \
    --reward_funcs accuracy format \
    --beta 0.04 \
    --report_to wandb \
    --dataset-name this_is_not_used \
    --deepspeed ${REPO_HOME}/src/open-r1-multimodal/local_scripts/zero2.json \
    --learning_rate 1e-5 \
    --use_peft true \
    --lora_r 64 \
    --lora_alpha 128 \
    --lora_dropout 0.05 \
    --lora_task_type CAUSAL_LM \
    --freeze_vision_modules true

echo "Training completed for ${EXP_NAME}"
