A small script to install [RASPA3](https://github.com/iRASPA/RASPA3) on TU Delft HPC cluster DelftBlue.

To use it, clone this repo and run `install.sh`:

```bash
git clone https://github.com/gabriblas/raspa3-delftblue.git
cd raspa-delftblue
chmod +x install.sh
./install.sh
```

The script will:
- Setup a directory to install Raspa to, which can be customised by editing the first lines of `install.sh`.
- Download the desired version of Raspa, and replace the `CMakePresets.txt` and `CMakeLists.txt` files with a version that works on DelftBlue (see the `patch` directory).
- Compile Raspa with AVX512 support and install it to `~/raspa`.
- Create a local `lmod` module for convenience (`module load raspa` should be enough to be up and running!)
	- For this to work, add `module use ~/raspa/modules` to your `.bashrc` (or run it every time you log in).

Notice that installing multiple versions of Raspa is supported (but not every version has been tested!). Moreover, **only the command line version of Raspa will be compiled** (no Python bindings!). This can be changed in `CMakePresets.txt`, but it has not been tested either.