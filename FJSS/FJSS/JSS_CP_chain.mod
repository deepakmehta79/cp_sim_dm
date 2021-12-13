/*********************************************
 * OPL 6.3 Model
 * Author: Cemalettin Ozturk
 * Creation Date: 26.Oca.2012 at 10:11:27
 *********************************************/
using CP;

int nbJobs=...;//number of jobs 
range jobs=1..nbJobs;//array of jobs which are distinct activities in fact

int nbMachines=...;//number of resources, in job shop they are resources
range machines=1..nbMachines;//array of machines

int time[1..nbJobs,1..nbMachines]=...;//processing time of each job on each machine

float readytime[machines]=...;//ready time of machines

//int con[jobs,jobs]=...;//conjunctive relations

int con[i in jobs,j in jobs]=0;//conjunctive relations

execute conjunctive{

for(var i=1;i<=nbJobs-1;i++){
			if(Math.ceil(i/10)==Math.ceil((i+1)/10))
				con[i][i+1]=1;
}
}

tuple operations{
int machine;
int job;
}

{operations}operation={<a,b>|a in machines,b in jobs:time[b][a]>0};

int M=sum(i in jobs,j in machines)time[i,j];

dvar interval Cmax in 0..M size 0;
dvar interval job[j in operation] in 0..M size time[j.job,j.machine];
dvar sequence resources[m in machines] in all(s in operation:s.machine==m)job[s];//sequence on resources

minimize
  endOf(Cmax);//minimize makespan

subject to{

forall(j in operation)
endOf(job[j])<=startOf(Cmax);//gives makespan

forall(i in machines)
noOverlap(resources[i]);//disjunctive global constraint in CP for resources

forall(j in operation, k in operation:con[j.job][k.job]==1)
	endBeforeStart(job[j],job[k]); //precedence constraint

forall(s in operation)//start time of activities are greater than ready time
startOf(job[s])>=readytime[s.machine];

};

main {
  cp.param.TimeLimit=3600;
  thisOplModel.generate();
  cp.startNewSearch();
    while (cp.next()) {
     writeln("makespan= ",cp.getObjValue());
     writeln("failures= ",cp.info.NumberOfFails);
     writeln("solution time= ",cp.info.SolveTime);
     writeln("----------------");
	 };
     writeln("number of constraints=",cp.info.NumberOfConstraints);
     writeln("number of variables=",cp.info.NumberOfModelVariables);
     writeln("runtime=",cp.info.TotalTime);
}
