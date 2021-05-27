# Downsizer

## Installation

Create and activate a conda env

```bash
conda create -y -p ./conda_env
conda activate ./conda_env
```

Install conda dependancies

```bash
conda install -y -c conda-forge snakemake mamba tibanna awscli
```

## Usage


### Local

```bash
snakemake --use-conda -j4 --config threads=4 tmp=/path/to/tmp input=/path/to/input output=/path/to/output normalisation=500000
```

### AWS


#### Upload data into s3 bucket

```bash
aws s3 cp input s3://data-hq6j5/input --recursive
```

#### Deploy Unicorn linked to data and db s3 buckets

```bash
tibanna deploy_unicorn -g downsizer -b data-hq6j5
```

Export

```bash
export TIBANNA_DEFAULT_STEP_FUNCTION_NAME=tibanna_unicorn_downsizer
```

#### Execution

```bash
snakemake --tibanna --use-conda -j 2 --default-remote-prefix=data-hq6j5 --config tmp=tmp input=input output=output normalisation=500000
```

#### Check logs

Display 

```bash
tibanna stat -l
```

```bash
tibanna log -j <jobid>
```


