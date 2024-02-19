import os,sys
import subprocess as sp
os.system("chmod -R 777 ~/scratch/")
"""
def newcomer():
  print("It seems like it's the 1st time you're using this tool")
  print("First, we will create a shortcut to your NFS personal folder")
  personalNFS=input("Input the absulute path of your NFS user folder without the / in the end:  ")
  os.system("ln -s "+personalNFS+" ~/nfs")
newperson=False
"""
squeue=True
"""
def autowiz():
  print("Welcome to the automated sbatch creator!\n Please note that the last autosteps.sbatch file will be overwritten\n\n")
  f=input("Input the 1st step you'd like to run: ")
  l=input("\nNow, the last step you'd like to run: ")
  if int(l)<=int(f):
    print("Error! The steps must be more than 1 and incremental, let's try again:\n\n")
    squeue=False
    autowiz()
  steps = open("autosteps.sbatch", "w")
  stps=list(range(int(f),int(l)))
  steps.write("#!/bin/bash\n#SBATCH --job-name=autoATAC\n#SBATCH --time=72:00:00\n#SBATCH --mem-per-cpu=16G\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --cpus-per-task=8\n#SBATCH --chdir=$HOME\n")
  steps.write("export scripts=$(realpath ~/nfs/scripts)\n")
  for x in stps:
    steps.write("\nsbatch --wait $scripts/S"+str(x)+".sbatch")
  steps.write("\nsbatch $scripts/S"+str(l)+".sbatch")
  steps.close()
  squeue=True
  os.system("sbatch autosteps.sbatch")
"""
def menu():
    print("Which step you want to run? \n \n")
    job_name=input("Input the name of the job you want to run (only letters and numbers): ")
    print("\nSelect the step you want to perform: ")
    cdir=sp.check_output("pwd")
    print(os.system("cat steps.txt"))
    print("write one step S1-S10 or auto for execute steps S2 to S6 automatically")
    step=input("Select the STEP:")
    os.system("cd ~/nfs/scripts")
    if step=="S1":
      os.system("sbatch S1.sbatch")
    elif step=="S2":
      os.system("sbatch S2.sbatch")
    elif step=="S3":
      os.system("sbatch S3.sbatch")
    elif step=="S4":
      os.system("sbatch S4.sbatch")
    elif step=="S5":
      os.system("sbatch S5.sbatch")
    elif step=="S6":
      os.system("sbatch S6.sbatch")
    elif step=="S7":
      os.system("sbatch S7.sbatch")
    elif step=="S8":
      os.system("sbatch S8.sbatch")
    elif step=="S9":
      os.system("sbatch S9.sbatch")
    elif step=="S10":
      os.system("sbatch S10.sbatch")
    elif step=="S11":
      os.system("sbatch S11.sbatch")
    elif step=="S12":
      os.system("sbatch S12.sbatch")
    elif step=="S13":
      os.system("sbatch S13.sbatch")
    elif step=="S14":
      os.system("sbatch S14.sbatch")
    #elif step=="auto":
      #autowiz()
    else:
      print("Invalid input, try again! :(")
      squeue=False
      menu()
    os.system("mkdir ~/scratch/"+job_name)
#if newperson==True:
#  newcomer()
#  newperson=False
menu()
if squeue==True:
  os.system("watch squeue")
