/*********************************************
 * OPL 6.3 Model
 * Author: Cemalettin Ozturk
 * Creation Date: 26.Oca.2012 at 10:11:27
 *********************************************/

execute{
cplex.tilim=900;} 

int nbJobs=...;
range jobs=1..nbJobs+2;

int nbMachines=...;
range machines=1..nbMachines;

float time[1..nbJobs,1..nbMachines]=...;

float readytime[machines]=...;

int con[1..nbJobs,1..nbJobs]=...;//conjunctive relations

float sdst[jobs,jobs]=...;

tuple operations{
int machine;
int job;
}

{operations}operation={<a,b>|a in machines,b in jobs:((b<=nbJobs)=>(time[b][a]>0))||(b>nbJobs)};

float duration[o in operation];
execute{
for(var o in operation){
	if(o.job<=nbJobs){
		duration[o]=time[o.job][o.machine];
		}
	else duration[o]=0;
	}
}


//execute{writeln(operation,Opl.card(operation))};

tuple disjunctives{
operations u;
operations v;	
}

//create all pairwise first operation,last operation pairs for disjunctive constraint
{disjunctives}disjunctive_first={<u,v>|u in operation, v in operation:(u.machine==v.machine)&&(u.job!=v.job)&&(u.job==nbJobs+1)&&(v.job!=nbJobs+1)};
{disjunctives}disjunctive_last={<u,v>|u in operation, v in operation:(u.machine==v.machine)&&(u.job!=v.job)&&(v.job==nbJobs+2)&&(u.job<=nbJobs+1)}; 
{disjunctives}disjunctive_real={<u,v>|u in operation, v in operation:(u.machine==v.machine)&&(u.job!=v.job)&&(v.job<=nbJobs)&&(u.job<=nbJobs)};

{disjunctives}disjunctive=disjunctive_first union disjunctive_last union disjunctive_real;

//execute{writeln(duration)};

float M=sum(i in 1..nbJobs,j in machines)(time[i,j])+sum(i in jobs,j in jobs)sdst[i,j];

float transfertime[machines][machines]=...;

dvar float+ start[operation];//starting time of each real job
dvar float+ Cmax;//makespan of the schedule
dvar boolean assigned[operation];//whether that operation exist or not
dvar boolean edge[disjunctive];//whether that edge exist or not

dvar boolean Q[operation][operation];

minimize Cmax;
subject to{

forall(j in jobs:j<=nbJobs)
sum(d in disjunctive:d.u.job==j)edge[d]==1;

forall(j in jobs:j<=nbJobs)
sum(d in disjunctive:d.v.job==j)edge[d]==1;

forall(o in operation:o.job==nbJobs+1)
sum(p in operation:(o.machine==p.machine)&&(o.job!=p.job))edge[<o,p>]==1;

forall(o in operation:o.job==nbJobs+2)
sum(p in operation:(o.machine==p.machine)&&(o.job!=p.job))edge[<p,o>]==1;

forall(s in operation:s.job==nbJobs+1)
start[s]==readytime[s.machine];//starting time of each first dummy operation is the ready time of that machine

forall(s in operation:s.job==nbJobs+2)
start[s]<=Cmax;//starting time of each last dummy operation is the makespan

forall(s in operation:s.job>nbJobs)//assigned machine of dummy operations are known
assigned[s]==1;

forall(j in jobs:j<=nbJobs)//assign each real job to only one machine
cons:sum(o in operation:o.job==j)assigned[o]==1;

forall(s in operation:s.job<=nbJobs){
start[s]<=assigned[s]*M;
};

forall(i in 1..nbJobs,j in 1..nbJobs:con[i][j]>0){//precedence relation
	sum(o in operation:o.job==j)start[o]>=sum(o in operation:o.job==i)start[o]+
		sum(o in operation:o.job==i)time[o.job][o.machine]*assigned[o]+
		sum(o in operation,p in operation:(o.job==i)&&(p.job==j))Q[o,p]*transfertime[o.machine,p.machine];
	};
	
forall(d in disjunctive){
assigned[d.u]+assigned[d.v]>=2*edge[d];
start[d.v]>=start[d.u]+duration[d.u]+sdst[d.u.job][d.v.job]*edge[d]-M*(1-edge[d]);
}

forall(a in operation, b in operation){
Q[a,b]+1>=assigned[a]+assigned[b];
2*Q[a,b]<=assigned[a]+assigned[b];
}
};


tuple gantts{
int machine;
int pred_job;
float start_p;
float time_p;
float complete_p;
float setup;
int suc_job;
float start_s;
float time_s;
float complete_s;
};

{gantts} gantt={<d.u.machine,d.u.job,start[d.u],duration[d.u],start[d.u]+duration[d.u],sdst[d.u.job][d.v.job],d.v.job,start[d.v],duration[d.v],start[d.v]+duration[d.v]>|d in disjunctive:edge[d]==1};

execute{writeln(gantt)};





