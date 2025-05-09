# EEOB5460_final_project2025

This github repository belongs to Lillian Chiang and was made as part of the group project for EEOB/BCB5460 for Spring 2025.
The group members for this project are Lillian Chiang, Swathi Nadendla, Shirin Parvin and Zheyuan Zhang.
The contents of the GitHub repo are as follows:
1. The author(s)-YEAR.md file, which in this case is called `Lillian_Swathi_Shirin_Zheyuan-2025.md` details out the paper we chose to work on and summarizes how we attempted replicating the workflow of the paper. This contains details of the sequence of the scripts we ran and potential files we generated.
2. A code directory called `Scripts` which contains all the scripts we used to perform our analyses. All scripts are self-explanatory with comments.
3. We have the script files in the home directory as well, since our scripts were designed to have them in the home directory when being run.

Please clone the repository in the ISU HPC since we pull a lot of tools from that installed in the HPC

We did not include any data directory since our starting files were too big to be uploaded on GitHub. However, all the data needed to replicate our analysis will be downloaded onto the local clone of the repo when the scripts are run as exlained in the `Lillian_Swathi_Shirin_Zheyuan-2025.md` file.
The data files are either hosted on Cybox or are directly downloaded from NCBI and other websites. 
Please note, there will be creation of multiple folders as the scripts are executed such as :
a. `patient_raw_fastq` which will contain the raw fastq files needed to start off the analysis.
b. `blast_db` which will contain the viral reference genome needed for the workflow.
c. `working_files`, which will contain all the working files generated during the workflow.
d. `output_files`, which will contain all the reports generated during the workflow.

Also, please note, since our workflow uses a lot of large files and several tools which are memory intensive, special attention needs to be paid to space.
We have further uploaded all the files we generated on Cybox which can be accessed using the following link: https://iastate.box.com/s/9qlcff3ikvxa2s0iyzsmpdac566s0m0d