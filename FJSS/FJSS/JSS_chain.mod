/*********************************************
 * OPL 6.3 Model
 * Author: Cemalettin Ozturk
 * Creation Date: 26.Oca.2012 at 10:11:27
 *********************************************/
int nbJobs=...;
range jobs=1..nbJobs;

int nbMachines=...;
range machines=1..nbMachines;

float time[1..nbJobs,1..nbMachines]=...;

float readytime[machines]=...;

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

tuple disjunctives{
operations c;
operations d;	
}

{disjunctives}disjunctive={<i,j>|i in operation,j in operation:(i.machine==j.machine)&&(i.job!=j.job)};

//execute{
//writeln(operation,Opl.card(operation))};
//writeln(disjunctive)};

float M=sum(i in jobs,j in machines)time[i,j];

dvar float+ start[jobs];//starting time of each job
dvar float+ Cmax;//makespan of the schedule
dvar boolean edge[disjunctive];//whether that edge exist or not

minimize Cmax;
subject to{

forall(i in jobs){
Cmax>=start[i]+sum(o in operation:o.job==i)time[o.job][o.machine];//makespan
start[i]>=sum(o in operation:o.job==i)readytime[o.machine];//starting time is greater than ready time
};
forall(i in jobs,j in jobs:con[i][j]>0){//precedence relation
	start[j]>=start[i]+sum(o in operation:o.job==i)time[o.job][o.machine];;
	}

forall(i in operation,j in operation:((i.machine==j.machine)&&(i.job<j.job))){//disjunctive relations
	edge[<j,i>]+edge[<i,j>]==1;
	start[i.job]>=start[j.job]+time[j.job][j.machine]-M*(1-edge[<j,i>]);
	start[j.job]>=start[i.job]+time[i.job][i.machine]-M*edge[<j,i>];
}

}

tuple gantts{
int machine;
int job;
float start;
float proc;
float comp;
};

{gantts}gantt={<a,b,start[b],time[b][a],start[b]+time[b][a]>|a in machines,b in jobs:(time[b,a]>0)};

execute{
writeln("machine "+"job"+" start"+" "+" time"+" end");
for(var i in gantt)
writeln(i)
};
