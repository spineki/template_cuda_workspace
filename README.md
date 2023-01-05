# Template Cuda Workspace

A template to bootstrap a cuda project

## Folder description

- data: all bloats of data (datasets, pictures, assets, etc)
  - fixtures: dummy data for tests
- external: other projects, used for comparative benchmarks
- include: header files
- src: cpp and cu files
- tests: tests suites (google test)
- tools: all automation scripts and tools we use to simplify the workflow

## Setup

### Clone the project

```
git clone https://gitlab-research.centralesupelec.fr/scalable-explicative-ml/randomforest-gpu.git
```

### Install the tools

(NB: the following sections might need to be updated once the GPU code will be written).

#### On Linux

You can open the [Dockerfile](./Dockerfile) at the root of this project and copy-paste all the installation-related commands.

#### On windows

There are 2 direct ways to compile this project.

##### WSL: (learn how to install it [here](https://learn.microsoft.com/en-us/windows/wsl/install))

- Open your WSL distribution (open a terminal and type `wsl`)
- Follow the [Linux section](#on-linux) of this README (you basically have a linux distribution)

##### Docker: You might want to run this project using a docker environment to keep your computer clean from dependencies.

- Check if you have [docker desktop](https://www.docker.com/products/docker-desktop/) installed on windows
- Open docker desktop before trying anything with docker
- In a **windows terminal** (not in a **wsl**), `cd` to the root of this project
- Start by creating a base image with all the necessary tools with the following command. BEWARE IT IS QUITE LARGE 6GB.
  `docker build -t base_gpu_random_forest_image .`
- Here you can choose how to interact with your environnement
  - If you want to interact with your image directly through the CLI (or if you like vim)
    - run your image with `docker run -it  --entrypoint "/bin/bash" -w "/app" --name dev_gpu_random_forest_container --mount type=bind,source="$(pwd)",target=/app base_gpu_random_forest_image`. The image will start and you will be in the /app folder
    - You now have a linux-like environment. You can read the rest of this readme as if you were using linux directly.
  - However, you may want to use vscode to plug yourself into the container, as if you were using ssh on a distant machine. To do so :
    - Start by running the image in detached mode `docker run -dit --entrypoint "/bin/bash" -w "/app" --name dev_gpu_random_forest_container --mount type=bind,source="$(pwd)",target=/app base_gpu_random_forest_image`
    - Then open `vscode` (Visual Studio Code), make sure you have the [docker](ms-azuretools.vscode-docker) extension installed
    - Click on the docker icon on the left side bar
    - Right click on the container, `Attach visual studio code`
    - Then go to the correct path: `ctrl + p` `/app`
    - You will now be able to see the source project from vscode and use the command line as if you were on linux.

### Compile the project for the first time

You will mainly interact with this project through `make` commands.
We automatised multiple scripts through the [project Makefile](./Makefile) ( Similar to a package.json script section ).

1. Then, try to run the project : `make run`
2. You can also compile without running with : `make compile`
3. Run the tests with `make tests`
4. You can also compile tests without running them with : `make compile-tests`
5. If you want to clean your installation : `make clean`

## Authors

Romain Bellon  
Thomas Kebaïli  
Antoine Marras
