# AUTOGENERATED! DO NOT EDIT! File to edit: 07_cli.ipynb (unless otherwise specified).

__all__ = ['app', 'search_folder', '__main__']

# Cell
import typer
from .core import queryFlow


# Cell
app = typer.Typer()

# Cell
@app.command()
def search_folder(path: str, query: str, n: int = 10):
    ranked = queryFlow(path, query)
    print(ranked[:n])
#     return(ranked)


# Cell
def __main__():
    app()