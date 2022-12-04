import plotly.express as px
import pandas as pd
import argparse

parser = argparse.ArgumentParser(description='graph')
parser.add_argument('--show', action=argparse.BooleanOptionalAction)
args = parser.parse_args()

def graph(csv_file, output_file, title, yaxis_title, nrows=9999):
    df = pd.read_csv(csv_file, nrows=nrows)
    fig = px.line(
            df,
            x='name',
            y=['sake', 'pyinfra', 'ansible'],
            title=title,
            labels={
                'name': 'Hosts',
                'sake': 'sake',
                'pyinfra': 'pyinfra',
                'ansible': 'ansible'
                },
            color_discrete_sequence=['#000000', '#53ac63', '#ee0000'],
            markers=True)

    fig.update_layout(
        legend=dict(
            title=None,
            orientation='h',
            yanchor='bottom',
            y=1.02,
            xanchor='right',
            x=1
        ),
        font=dict(
            size=14,
            color='#24292f',
        ),
        xaxis_title='Hosts',
        yaxis_title=yaxis_title,
        )

    if args.show:
        fig.show()

    fig.write_image(output_file)

def main():
    graph(csv_file='./results/test-case-1/csv/time.csv', output_file='./results/test-case-1/images/time-short.png', title='Ping (Elapsed Time)', yaxis_title='Time (s)', nrows=7)
    graph(csv_file='./results/test-case-2/csv/time.csv', output_file='./results/test-case-2/images/time-short.png', title='Commands (Elapsed Time)', yaxis_title='Time (s)', nrows=7)

    graph(csv_file='./results/test-case-1/csv/time.csv', output_file='./results/test-case-1/images/time.png', title='Test 1 - Ping (Elapsed Time)', yaxis_title='Time (s)')
    graph(csv_file='./results/test-case-1/csv/cpu.csv', output_file='./results/test-case-1/images/cpu.png', title='Test 1 - Ping (CPU)', yaxis_title='CPU (%)')
    graph(csv_file='./results/test-case-1/csv/mem.csv', output_file='./results/test-case-1/images/mem.png', title='Test 1 - Ping (Memory)', yaxis_title='Memory (MB)')

    graph(csv_file='./results/test-case-2/csv/time.csv', output_file='./results/test-case-2/images/time.png', title='Test 2 - Commands (Elapsed Time)', yaxis_title='Time (s)')
    graph(csv_file='./results/test-case-2/csv/cpu.csv', output_file='./results/test-case-2/images/cpu.png', title='Test 2 - Commands (CPU)', yaxis_title='CPU (%)')
    graph(csv_file='./results/test-case-2/csv/mem.csv', output_file='./results/test-case-2/images/mem.png', title='Test 2 - Commands (Memory)', yaxis_title='Memory (MB)')

if __name__ == "__main__":
    main()
