#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --mem=12g
#SBATCH --array=0-11%4
##SBATCH --nodelist=compute-0-7
#SBATCH -t 0

declare -a klw=("0.001" "0.01" "0.03" "0.05" "0.1" "0.5")
declare -a anneal=("-1" "3")

arglen1=${#klw[@]}
arglen2=${#anneal[@]}

taskid=${SLURM_ARRAY_TASK_ID}

i=$(( taskid/arglen2 ))
j=$(( taskid%arglen2 ))

python src/main.py \
  --dataset sr_bos \
  --clean_mem_every 5 \
  --reset_output_dir \
  --classifier_dir="pretrained_classifer/decipher" \
  --data_path data/test/ \
  --train_src_file data/sr_bos/train.spm32000.txt \
  --train_trg_file data/sr_bos/train.attr \
  --dev_src_file data/sr_bos/dev.spm32000.txt \
  --dev_trg_file data/sr_bos/dev.attr \
  --dev_trg_ref data/sr_bos/dev_ref.txt \
  --src_vocab  data/sr_bos/text.spm32000.vocab \
  --trg_vocab  data/sr_bos/attr.vocab \
  --d_word_vec=128 \
  --d_model=512 \
  --log_every=100 \
  --eval_every=3000 \
  --ppl_thresh=10000 \
  --eval_bleu \
  --batch_size 32 \
  --valid_batch_size 128 \
  --patience 5 \
  --lr_dec 0.5 \
  --lr 0.001 \
  --dropout 0.3 \
  --max_len 10000 \
  --seed 0 \
  --beam_size 1 \
  --word_blank 0. \
  --word_dropout 0. \
  --word_shuffle 0 \
  --cuda \
  --anneal_epoch ${anneal[$j]} \
  --temperature 0.01 \
  --klw ${klw[$i]} \
  --max_pool_k_size 1 \
  --merge_bpe \
  --bt \
  --lm \
  --avg_len \
  --bt_stop_grad \
  # --gumbel_softmax \
  # --gs_soft \
