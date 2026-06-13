---
title: "10. Reproduceerbare Python development-omgevingen"
subtitle: "Linux (for data Scientists)<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem, Jan Willem
date: 2025-2026
---

# Pyhon package management

## It's complicated

- Python versie (2 vs 3, 3.n vs 3.n+1)
- `apt` packages vs `pip` packages
- Systeembreed vs user vs project

## Best practices

- Systeembreed? Gebruik enkel distro package manager
  - Kan verouderde versie zijn!
- Specifiek voor gebruiker, bv. `pip install --user ...`
  - Wordt nu vaak uitgeschakeld!
- Per project? Gebruik een *virtuele omgeving* (venv)

---

```console
hogent@LinuxGUI:~$ pip install --user numpy
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
    ...
hint: See PEP 668 for the detailed specification.
```

## Virtuele omgeving

- Binnen project-directory
- "Afgeschermde" Python omgeving
  - Python-versie
  - Package mgmt met `pip`
  - Packages met specifieke versies
- Toepassing van *environment variables*

## Aan de slag

- Zorg dat `python3-venv` package geïnstalleerd is
  - `sudo apt install python3-venv`
- Maak een directory voor je project
  - Voeg Python code toe
- Maak een virtuele omgeving aan
  - `python3 -m venv .venv`

## Voorbeeldcode

- Sla op als `penguins.py`
- Let op de shebang!
- Deps: Seaborn, scikit-learn

```python
#! /usr/bin/env python3
import seaborn as sns
from sklearn.linear_model import LinearRegression

# Load the Palmer Penguins demo dataset
penguins = sns.load_dataset('penguins')
# Select only needed colums and drop NaNs
df_flipper_mass = penguins[['flipper_length_mm', 'body_mass_g']].dropna()

# Build linear regression model
lm_flipper_mass = LinearRegression().fit(
    df_flipper_mass[['flipper_length_mm']].values,
    df_flipper_mass[['body_mass_g']].values)

# Print regression line coefficients
print(f"Regression line: mass = %.4f + %.4f x fl_length" %
      (lm_flipper_mass.intercept_[0], lm_flipper_mass.coef_[0,0]))
```

---

```python
# Plot scatter plot for flipper length and body mass
plot_flipper_mass = sns.relplot(data=penguins,
    x='flipper_length_mm', y='body_mass_g', 
    hue='species', style='sex');

# Add regression line to the plot
sns.regplot(data=df_flipper_mass,
    x='flipper_length_mm', y='body_mass_g',
    scatter=False, ax=plot_flipper_mass.ax);

# Save to output/ directory (is expected to exist!)
plot_flipper_mass.figure.savefig('output/penguins_flipper_mass.png')
```

## Virtuele omgeving aanmaken

```console
hogent@LinuxGUI:~/penguins$ chmod +x penguins.py
hogent@LinuxGUI:~/penguins$ ls -l
total 4
-rwxr-xr-x 1 hogent users 1126 Oct 15 12:57 penguins.py
hogent@LinuxGUI:~/penguins$ python3 -m venv .venv
```

## Inhoud .venv

- `bin/`: Python interpreter, `pip`, ...
  - `activate` script (bekijk de inhoud!)
- `lib/`, `lib64/`: Python libraries

```console
hogent@LinuxGUI:~/penguins$ ls .venv/
bin  include  lib  lib64  pyvenv.cfg
hogent@LinuxGUI:~/penguins$ ls .venv/bin/
activate  activate.csh  activate.fish  Activate.ps1  pip  pip3  pip3.13  python  python3  python3.13
hogent@LinuxGUI:~/penguins$ ls .venv/lib/python3.13/site-packages/
pip  pip-25.1.1.dist-info
```

## Activatie

```console
hogent@LinuxGUI:~/penguins$ source .venv/bin/activate
(.venv) hogent@LinuxGUI:~/penguins$ which python3
/home/hogent/penguins/.venv/bin/python3
(.venv) hogent@LinuxGUI:~/penguins$ which pip
/home/hogent/penguins/.venv/bin/pip
```

Let op het `source` command!

## Probeer het script uit!

```console
(.venv) hogent@LinuxGUI:~/penguins$ mkdir output
(.venv) hogent@LinuxGUI:~/penguins$ ./penguins.py
Traceback (most recent call last):
  File "/home/hogent/penguins/penguins.py", line 6, in <module>
    import seaborn as sns;
    ^^^^^^^^^^^^^^^^^^^^^
ModuleNotFoundError: No module named 'seaborn'
```

## Dependencies installeren

```console
(.venv) hogent@LinuxGUI:~/penguins$ pip install seaborn scikit-learn
Collecting seaborn
[...veel output weggelaten...]
Successfully installed ...
```

## Probeer opnieuw

```console
(.venv) hogent@LinuxGUI:~/penguins$ ./penguins.py
Regression line: mass = -5780.8314 + 49.6856 x fl_length
(.venv) hogent@LinuxGUI:~/penguins$ ls -l output/
total 84
-rw-r--r-- 1 hogent users 83224 Oct 15 13:30 penguins_flipper_mass.png
```

## Reproduceerbaarheid

```console
(.venv) hogent@LinuxGUI:~/penguins$ pip freeze > requirements.txt
(.venv) hogent@LinuxGUI:~/penguins$ nano requirements.txt
```

Syntax requirements.txt:

- `package==versie`
- `package>=versie`
- `package>=versie,<versie`

## Test reproduceerbaarheid

Verwijder de virtuele omgeving:

```console
(.venv) hogent@LinuxGUI:~/penguins$ deactivate
hogent@LinuxGUI:~/penguins$ rm -rf .venv
hogent@LinuxGUI:~/penguins$ rm output/*
hogent@LinuxGUI:~/penguins$ tree
.
├── output
├── penguins.py
└── requirements.txt

2 directories, 2 files
```

## Bouw opnieuw

```console
hogent@LinuxGUI:~/penguins$ python3 -m venv .venv
hogent@LinuxGUI:~/penguins$ source .venv/bin/activate
(.venv) hogent@LinuxGUI:~/penguins$ pip install -r requirements.txt
(.venv) hogent@LinuxGUI:~/penguins$ ./penguins.py 
Regression line: mass = -5780.8314 + 49.6856 x fl_length
(.venv) hogent@LinuxGUI:~/penguins$ tree
.
├── output
│   └── penguins_flipper_mass.png
├── penguins.py
└── requirements.txt

2 directories, 3 files
```

## Reproduceerbaarheid in Docker

Creeer een `Dockerfile`:

```dockerfile
# Running a Python application with dependencies in a Docker container
FROM python:3.13-slim

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

# Run the application:
COPY penguins.py .
CMD [ "python", "penguins.py" ]
```

## Build & run

(verwijder eerst opnieuw `.venv/` en de inhoud van `output/`)

```console
hogent@LinuxGUI:~/penguins$ docker build -t local:penguins-app .
[...veel output weggelaten...]
hogent@LinuxGUI:~/penguins$ docker run --rm -v "${PWD}/output":/app/output local:penguins-app
Regression line: mass = -5780.8314 + 49.6856 x fl_length
hogent@LinuxGUI:~/penguins$ tree
.
├── Dockerfile
├── output
│   └── penguins_flipper_mass.png
├── penguins.py
└── requirements.txt

2 directories, 4 files
```

