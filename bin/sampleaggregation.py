#!/usr/bin/env python
import time
import argparse
import os
from pathlib import Path
import pandas as pd

def get_args():
    # Script description
    description = """Aggregation of csv files from a directory"""
    # Add parser
    parser = argparse.ArgumentParser(description=description, formatter_class=argparse.RawDescriptionHelpFormatter)

    # Sections
    inputs = parser.add_argument_group(title="Required Input", description="Path to required input file")
    inputs.add_argument("-i", "--input", dest="input", action="store", required=True, help="File path to input directory")
    inputs.add_argument("-o", "--output", dest="output", action="store", required=True, help="Path to output directory")
    inputs.add_argument("--version", action="version", version="0.1.0")
    args = parser.parse_args()

    # Standardize paths
    args.input  = Path(args.input)
    args.output = Path(args.output)

    return args

def stack_csv_files(csv_dir) -> pd.DataFrame:

    #check if the directory exists
    if not csv_dir.exists():
        raise ValueError(f"Path not found: {csv_dir}")
    if not csv_dir.is_dir():
        raise ValueError(f"{csv_dir} is not a directory")

    files = os.listdir(csv_dir)
    csv_files = [f for f in files if f.endswith('.csv')]
    df = pd.DataFrame()
    for file in csv_files:
        df_file = pd.read_csv(os.path.join(csv_dir, file))
        #check if the column exists
        if 'sampleid' in df_file.columns:
            df = pd.concat([df, df_file], ignore_index=True)
        else:
            df_file['sampleid'] = file[:-4]
            df = pd.concat([df, df_file], ignore_index=True)
    return df

def main(args):
    df = stack_csv_files(args.input)
    df.to_csv(args.output, index=False)

if __name__ == "__main__":
    # Read in arguments
    args = get_args()

    # Run script
    st = time.time()
    main(args)
    rt = time.time() - st
    print(f"Script finished in {rt // 60:.0f}m {rt % 60:.0f}s")
