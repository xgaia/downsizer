import glob
import os
import re

from datetime import datetime


current_path = os.path.dirname(os.path.abspath(__name__))

configfile: "{}/config.yaml".format(current_path)

# Variables
TMP = "{}".format(config["tmp"])
RESULTS = "{}".format(config["output"])
INPUT = "{}".format(config["input"])
NORMALISATION = config["normalisation"]
THREADS = config["threads"]

# Set number of threads (max 16)
if THREADS > 16:
    THREADS = 16

# Get wildcard input list
LIST_FILES = glob.glob("{}/*.fastq.gz".format(INPUT))
LIST_NAME = []
for name in LIST_FILES:
    file_name = re.sub("{}/".format(INPUT), "", name)
    name = re.sub("\d.fastq.gz", "", file_name)
    LIST_NAME.append(name)

# Uniq list
LIST_NAME = list(set(LIST_NAME))

def get_downsized_files(names):
    liste = []
    for name in names:
        liste.append("{}/downsized_{}1.fastq".format(RESULTS, name))
        liste.append("{}/downsized_{}2.fastq".format(RESULTS, name))
    return liste


########################### PIPELINE ###########################

rule all:
    input:
        get_downsized_files(LIST_NAME)

rule downsize:
    input:
        fwd=TMP+"/{sample}1.fastq",
        rev=TMP+"/{sample}2.fastq",
    output:
        fwd="{RESULTS}/downsized_{sample}1.fastq",
        rev="{RESULTS}/downsized_{sample}2.fastq"
    conda:
        "envs/downsize.yml"
    shell:
        "seqtk sample -s100 {input.fwd} {NORMALISATION} > {output.fwd} && seqtk sample -s100 {input.rev} {NORMALISATION} > {output.rev}"

rule gunzip:
    input:
        fastqgz=INPUT + "/{file}.fastq.gz"
    output:
        fastq=temp("{TMP}/{file}.fastq")
    shell:
        "gunzip {input.fastqgz} -c > {output.fastq}"
