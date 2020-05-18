# Lambda Notes

### Install on Ubuntu (with Lambda Stack 18.04)

__Anaconda__
Download and install the latest Python 3 Anaconda from: https://www.anaconda.com/download/. I prefer not to use conda for default Python. Also you should disable the base environment from appearing in the terminal.


``
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
chmod +x Anaconda3-2020.02-Linux-x86_64.sh
./Anaconda3-2020.02-Linux-x86_64.sh
conda config --set auto_activate_base false
``


```
git clone https://github.com/chuanli11/faceswap.git
cd faceswap
conda create -n venv-faceswap python=3.6
conda activate venv-faceswap

# Run this and select N to amd, docker, select Y to CUDA
python setup.py

```


### Usage

__Face Detection__

```
python faceswap.py extract -i data/src/trump/trump.mp4 -o data/faces/trump --masker unet-dfl && \
python faceswap.py extract -i data/src/fauci/fauci.mp4 -o data/faces/fauci --masker unet-dfl
```

__Train__

```
rm -rf /tmp/chuan/faceswap/trump_fauci_model_realface/ && \
python faceswap.py train \
-A /tmp/chuan/faceswap/data/faces/trump \
-B /tmp/chuan/faceswap/data/faces/fauci \
-m /tmp/chuan/faceswap/trump_fauci_model_realface/ \
-g 1 -nac -nf -it 200 -L DEBUG -t dfl-sae -bs 256


rm -rf ~/faceswap/trump_fauci_model_realface/ && \
python faceswap.py train \
-A ~/faceswap/data/faces/trump \
-B ~/faceswap/data/faces/fauci \
--alignments-A=~/faceswap/data/src/trump/trump_alignments.fsa \
--alignments-B=~/faceswap/data/src/fauci/fauci_alignments.fsa \
-m ~/faceswap/trump_fauci_model_realface/ \
-g 2 -nac -nf -it 20 -L DEBUG -t dfl-h128 -bs 64

rm -rf ~/faceswap/trump_fauci_model_realface/ && \
python faceswap.py train \
-A ~/faceswap/data/faces/trump \
-B ~/faceswap/data/faces/fauci \
--alignments-A=~/faceswap/data/src/trump/trump_alignments.fsa \
--alignments-B=~/faceswap/data/src/fauci/fauci_alignments.fsa \
-m ~/faceswap/trump_fauci_model_realface/ \
-g 2 -nac -nf -it 20 -L DEBUG -t dfl-h128 -bs 128
```


__Benchmark__

```
./speed_benchmark.sh
```

__Use Mask__

Need to set `mask_type` and `learn_mask` accordingly in `config/train.ini`
