# conda create -n vlm-r1 python=3.11 
# conda activate vlm-r1

# Install the packages in open-r1-multimodal .
cd src/open-r1-multimodal # We edit the grpo.py and grpo_trainer.py in open-r1 repo.
pip install -e ".[dev]"

# Addtional modules
pip install json_repair
pip install -U peft

pip install wandb==0.18.3
pip install tensorboardx
pip install qwen_vl_utils torchvision

# pip install flash-attn --no-build-isolation
pip install torch=='2.4.1+cu121' torchvision=='0.19.1+cu121' torchaudio=='2.4.1+cu121'  --index-url https://download.pytorch.org/whl/cu121
MAX_JOBS=16 pip install flash-attn==2.6.3 --no-build-isolation

pip install babel
pip install python-Levenshtein
pip install matplotlib
pip install pycocotools
pip install openai
pip install httpx[socks]