import pandas as pd
import argparse

def process_bedgraph(file, prefix):
    df = pd.read_csv(file, sep='\t', skiprows=1, header=None,
                     names=['chr', 'start', 'end', 'methylation_rate', 'meth_count', 'unmeth_count'])
    df = df[['chr', 'start', 'methylation_rate']]
    df.rename(columns={'meth_count': f'{prefix}_{file.split("/")[-1].split(".")[0]}'}, inplace=True)
    return df

def main(target_files, background_files, output):
    target_dfs = [process_bedgraph(f, 'target') for f in target_files]
    background_dfs = [process_bedgraph(f, 'background') for f in background_files]

    # Merge all files
    merged_df = target_dfs[0]
    for df in target_dfs[1:] + background_dfs:
        merged_df = pd.merge(merged_df, df, on=['chr', 'start'], how='outer')

    merged_df.fillna('NA', inplace=True)
    merged_df.to_csv(output, sep='\t', index=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Merge bedGraph files.')
    parser.add_argument('--target_files', nargs='+', required=True, help='List of target bedGraph files.')
    parser.add_argument('--background_files', nargs='+', required=True, help='List of background bedGraph files.')
    parser.add_argument('--output', required=True, help='Output merged file path.')
    
    args = parser.parse_args()
    main(args.target_files, args.background_files, args.output)