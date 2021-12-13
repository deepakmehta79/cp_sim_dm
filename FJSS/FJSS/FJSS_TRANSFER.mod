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

int con[jobs,jobs]=...;//conjunctive relations

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

float transfertime[machines][machines]=...;

float M=sum(i in jobs,j in machines)time[i,j]+sum(k in machines, r in machines)transfertime[k][r];

dvar float+ start[jobs];//starting time of each job
dvar float+ Cmax;//makespan of the schedule
dvar boolean assigned[operation];//whether that operation exist or not
dvar boolean edge[disjunctive];//whether that edge exist or not

dvar boolean Q[operation][operation];//whether two operations are assigned to the corresponding operation.machine or not

minimize Cmax;
subject to{

forall(i in jobs){
sum(o in operation:o.job==i)assigned[o]==1;//assign each job to exactly one machine
Cmax>=start[i]+sum(o in operation:o.job==i)time[o.job][o.machine]*assigned[o];//makespan
start[i]>=sum(o in operation:o.job==i)readytime[o.machine]*assigned[o];//starting time is greater than ready time

};
forall(i in jobs,j in jobs:con[i][j]>0){//precedence relation
	start[j]>=start[i]+sum(o in operation:o.job==i)time[o.job][o.machine]*assigned[o]+
			sum(o in operation,p in operation:(o.job==i)&&(p.job==j))Q[o,p]*transfertime[o.machine,p.machine];;
	}

forall(i in operation,j in operation:((i.machine==j.machine)&&(i.job<j.job))){//disjunctive relations
	assigned[i]+assigned[j]>=2*(edge[<i,j>]+edge[<j,i>]);
	assigned[i]+assigned[j]<=edge[<i,j>]+edge[<j,i>]+1;
	start[i.job]>=start[j.job]+time[j.job][j.machine]-M*(1-edge[<j,i>]);
	start[j.job]>=start[i.job]+time[i.job][i.machine]-M*(1-edge[<i,j>]);
}

forall(a in operation, b in operation){
Q[a,b]+1>=assigned[a]+assigned[b];
2*Q[a,b]<=assigned[a]+assigned[b];
}
}

tuple gantts{
int machine;
int job;
float start;
float proc;
float comp;
};

{gantts}gantt={<a,b,start[b],time[b][a],start[b]+time[b][a]>|a in machines,b in jobs:(time[b,a]>0)&&(assigned[<a,b>]==1)};

execute{
writeln("machine "+"job"+" start"+" "+" time"+" end");
for(var i in gantt)
writeln(i)
};
