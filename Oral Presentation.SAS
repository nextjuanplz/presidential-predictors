/*
Oral Presentation
Juan Manuel Alzate Vanegas
STA 4164
2/23/2018
*/

/*Data on election races
Retrieved from DailyKos: https://dailykos.com/stories/2016/11/25/1601042/-Nerd-Alert-This-spreadsheet-contains-every-presidential-election-by-state-from-1828-to-2016
*/
data RawElectionData (drop = ii);
	*Read in data;
	*Laptop version:; 
	infile '\\Client\C$\Users\juanm\Dropbox\School\University of Central Florida\2017 - 2018\Spring 2018\STA 4164\Assignments\Oral Presentation\RawElectionData.csv' delimiter = ',' dsd;
	*PC version
	infile '\\Client\E$\Users\nextjuanplz\Dropbox\School\University of Central Florida\2017 - 2018\Spring 2018\STA 4164\Assignments\Oral Presentation\RawElectionData.csv' delimiter = ',' dsd;

	*Read in identifiable variables;	
	input Year Party $ Candidate $ @;

	*Read in votes for each state;
	array states (52) $ _temporary_  ('Nationwide', 'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut',
	'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas',
	'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
	'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'NewHampshire', 'NewJersey',
	'NewMexico', 'NewYork', 'NorthCarolina', 'NorthDakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
	'RhodeIsland', 'SouthCarolina', 'SouthDakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia',
	'Washington', 'WestVirginia', 'Wisconsin', 'Wyoming', 'DC');
	do ii = 1 to 52;
		*Save the state name;
		State = states(ii);

		*Save the votes for that state;
		input Vote @;

		*Ignore elections where candidate was not on ballot;
		if Vote = 0 then Vote = .;

		*Mark baseline year for nationwide;
		if State = 'Nationwi' then BaselineYear = 1828;
		else BaselineYear = 1964;

		*Mark as a separate observation;
		output;
	end;
run;

/*
*Print the first 100 observations;
proc print data = RawElectionData (obs = 100);
	title 'Election Results';
run;
/*

/*Analysis of totals*/

*Find totals for each state;
proc sql;
	create table Totals as
	select
		Year, State, Vote as Total, BaselineYear
		from RawElectionData
		where Party = 'TOT' and not missing(Vote) and Year le 2016;
quit;

/*
*Export for heat map
proc export data = Totals
  dbms = csv
  outfile = "\\Client\C$\Users\juanm\Dropbox\School\University of Central Florida\2017 - 2018\Spring 2018\STA 4164\Assignments\Oral Presentation\SASHeatMapData.csv";
run;
*/

proc sort data = Totals; by State Year;
run;
proc sql;
	*Check from earliest year where data is available for all;
	create table BaselineVote as
	select State, Total as Baseline
	from Totals
	where Year = BaselineYear;
quit;

proc sort data = BaselineVote; by State;
run;

data TotalData;
	*Fetch totals and baselines;
	merge Totals BaselineVote; by State; 

	*Mark % turnout relative to first election;
	if missing(Baseline) then RelativeVote = .;
	else if State = 'Nationwi' then RelativeVote = Total / 1116457;
	else RelativeVote = Total / Baseline;
run;

*Nationwide turnout over the years;
data NationWideTurnout;
	set TotalData; by State;
	if State ne 'Nationwi' then delete;
run;
proc sgplot data = NationWideTurnout noautolegend;
	*Modifications;
	format RelativeVote percent4.2;
	title 'Nationwide Change in Voter Turnout';
	xaxis label = "Year" interval = year grid minorgrid;
	yaxis label = "Number of Votes" grid minorgrid;
    *Scatterplot of turnout over the years by state;
	loess x = Year y = Total;
run;

*Turnout over the years by region;
data TotalsSubset;
	set TotalData; by State;
	if State = 'Nationwi' or Year < 1964 then delete;
	if State in ('Alabama', 'Kentucky', 'Mississi', 'Tennesse', 'Arkansas', 'Louisian', 'Oklahoma',
				'Texas', 'Delaware', 'Florida', 'Georgia', 'Maryland', 'NorthCar', 'SouthCar',
				'Virginia', 'DC', 'WestVirg') then Region = 'South';	
	else if State in ('NewJerse', 'NewYork', 'Pennsylv', 'Connecti', 'Maine', 'Massachu', 'NewHamps', 'RhodeIsl',
				'Vermont') then Region = 'Northeast';
	else if State in ('Iowa', 'Kansas', 'Minnesot', 'Missouri', 'Nebraska', 'NorthDak', 'SouthDak', 'Illinois',
				'Indiana', 'Michigan', 'Ohio', 'Wisconsi') then Region = 'Midwest';
	else if State in ('Alaska', 'Californ', 'Hawaii', 'Oregon', 'Washingt', 'Arizona', 'Colorado', 'Idaho',
				'Montana', 'Nevada', 'NewMexic', 'Utah', 'Wyoming') then Region = 'West';
run;
data SouthSubset;
	set TotalsSubset; by State;
	if Region ne 'South' then delete;
run;
data NortheastSubset;
	set TotalsSubset; by State;
	if Region ne 'North' then delete;
run;
data WestSubset;
	set TotalsSubset; by State;
	if Region ne 'West' then delete;
run;
data MidwestSubset;
	set TotalsSubset; by State;
	if Region ne 'Midwe' then delete;
run;
proc sgplot data = SouthSubset;
	*Modifications;
	format RelativeVote percent4.2;
	title 'Change in Voter Turnout in the South';
	xaxis label = "Year";
	yaxis label = "% Change in Turnout Relative to 1964";
	*Scatterplot of turnout over the years by state;
	loess x = Year y = RelativeVote / group = State;
run;
proc sgplot data = NortheastSubset;
	*Modifications;
	format RelativeVote percent4.2;
	title 'Change in Voter Turnout in the Northeast';
	xaxis label = "Year";
	yaxis label = "% Change in Turnout Relative to 1964";
	*Scatterplot of turnout over the years by state;
	loess x = Year y = RelativeVote / group = State;
run;
proc sgplot data = WestSubset;
	*Modifications;
	format RelativeVote percent4.2;
	title 'Change in Voter Turnout in the West';
	xaxis label = "Year";
	yaxis label = "% Change in Turnout Relative to 1964";
	*Scatterplot of turnout over the years by state;
	loess x = Year y = RelativeVote / group = State;
run;
proc sgplot data = MidwestSubset;
	*Modifications;
	format RelativeVote percent4.2;
	title 'Change in Voter Turnout in the Midwest';
	xaxis label = "Year";
	yaxis label = "% Change in Turnout Relative to 1964";
	*Scatterplot of turnout over the years by state;
	loess x = Year y = RelativeVote / group = State;
run;


/*Calculating wins*/

proc sort data = RawElectionData; by State Year;
run;

data ElectionData;
	*Fetch totals and baselines;
	merge RawElectionData TotalData; by State Year;
run;

proc sql;
	create table PercentVotes as
	select Year, State, max(Vote) as WinningVote
	from ElectionData
	where Party ne 'TOT'
	group by Year, State;
quit;

proc sort data = PercentVotes; by State Year;
run;

data ElectionData2;
	merge ElectionData PercentVotes; by State Year;
	if missing(Vote) then delete;
	if Party ne 'TOT' then PercentVote = Vote / Total;
run;

proc sort data = ElectionData2; by State Year;
run;

/*
proc print data = ElectionData2 (obs = 100);
	title 'Subset of Election Results';
run;
*/

data Elections (drop = WinningVote);
	set ElectionData2; by State Year;
	*Delete non-winning observations;
	if missing(Vote) then delete;

	*Popular vote wins;
	if Vote = WinningVote then Winner = 1;
    else Winner = 0;

	*Exceptions where popular vote did not win national election;
	if State = 'Nationwi' then do;
		if Year = 1876 then do;
			if Candidate = 'Rutherfo' then Winner = 1;
			else Winner = 0;
			return;
		end;
		if Year = 1888 then do;
			if Candidate = 'Benjamin' then Winner = 1;
			else Winner = 0;
			return;
		end;
		if Year = 2000 then do;
			if Candidate = 'GeorgeWB' then Winner = 1;
			else Winner = 0;
			return;
		end;
		if Year = 2016 then do;
			if Candidate = 'DonaldTr' then Winner = 1;
			else Winner = 0;
			return;
		end;
	end;
run;

/*
proc print data = Elections;
	title 'Election Results';
run;
*/

proc sql;
	create table PresidentTable as
	select Year, Candidate as PresidentElect
	from Elections
	where State = 'Nationwi' and Winner = 1 and Candidate ne 'Total';
quit;

proc sort data = PresidentTable; by Year;
run;

proc print data = PresidentTable; 
	title 'President-Elects by Election';
run;


proc sort data = Elections; by Year;
run;

data ElectionsFinal;
	merge Elections PresidentTable; by Year;
	*Remove totals;
	if Party = 'TOT' then delete;
	*Check each state;
	if State ne 'Nationwi' then do;
		*Create dichotomous variable to mark if state-winning candidate is overall;
		if compare(Candidate, PresidentElect) = 0 then do; 
			*Variable only exists for observations where president elect ran;
			if Winner = 1 then PredictiveOfWinner = 1;
			else PredictiveOfWinner = 0;
		end;
		else do;
			/*
			if Winner = 1 then PredictiveOfWinner = 0;
			else PredictiveOfWinner = 1;
			*/
			PredictiveOfWinner = .;
		end;
	end;

	*Remove Nationwide ones;
	else delete;
run;

proc sort data = ElectionsFinal; by Year;
run;

proc print data = ElectionsFinal (obs = 50);
	title 'Election Data';
run;


/*
proc print data = ElectionsFinal;
	title 'Election Results';
run;
*/
data PartyElections;
	set ElectionsFinal; by Year;
	if Party not in ('DEM', 'REP') then delete;
run;

*Which party wins most often;
proc freq data = PartyElections;
	title 'Party as Predictor of State Election Winner';
	tables Party * Winner / chisq;
run;

*Which state is most predictive;
proc freq data = ElectionsFinal;
	title 'Analysis of State Predictability of General Election Winner';
	*Participation of parties;
	*tables Party / chisq;
	*Chi-square analysis of which candidate wins most often;
	*tables Candidate * Winner / chisq;
	*Chi-square analysis of which state is most predictive;
	tables State * PredictiveOfWinner / chisq;
run;

/*Multivariate analysis*/

/*State predictiveness of election winner*/
/*
*Model A1: State Year State*Year;
proc probit data = ElectionsFinal;
  title 'Model A1: State Year State*Year';
  class State PredictiveOfWinner Year;
  model PredictiveOfWinner (event = '1') = State|Year@2;
  *lsmeans State*Year;
run;
*/
*Model A2: State * Year;
proc probit data = ElectionsFinal;
  title 'Model A2: State * Year';
  class State PredictiveOfWinner;
  model PredictiveOfWinner (event = '1') = State * Year;
  *lsmeans State*Year;
run;
*Model A3: State;
proc probit data = ElectionsFinal;
  title 'Model A3: State';
  class State PredictiveOfWinner;
  model PredictiveOfWinner (event = '1') = State;
run;
*Model A4: State Party;
proc probit data = ElectionsFinal;
  title 'Model A4: State Party';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner (event = '1') = State Party;
run;
*Model A5: State*Party;
proc probit data = ElectionsFinal;
  title 'Model A5: State*Party';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner (event = '1') = State*Party;
run;
*Model A6: State Party State*Party;
proc probit data = ElectionsFinal;
  title 'Model A6: State Party State*Party';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner (event = '1') = State Party State*Party;
run;
*Model A7: Party State*Party;
proc probit data = ElectionsFinal;
  title 'Model A6: Party State*Party';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner (event = '1') = Party State*Party;
run;
*GLM Logit;
proc genmod data = ElectionsFinal descending;
  title 'GLM';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner = Party State*Party
						   /dist = bin
                           link = logit
                           lrci;
run;
*GLM Probit;
proc genmod data = ElectionsFinal descending;
  title 'GLM';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner = Party State*Party
						   /dist = bin
                           link = probit
                           lrci;
run;



/*Predictor of winner by party and candidate*/
/*
*Model B1: Party*Candidate*Year;
proc probit data = ElectionsFinal;
  title 'Model B1: Party*Candidate*Year';
  class Party Candidate Winner;
  model Winner = Party*Candidate*Year;
run;
*Model B2: Party*Year Candidate*Year;
proc probit data = ElectionsFinal;
  title 'Model B2: Party*Year Candidate*Year';
  class Party Candidate Winner;
  model Winner = Party*Year Candidate*Year;
run;
*Model B3: Party*Year Candidate;
proc probit data = ElectionsFinal;
  title 'Model B3: Party*Year Candidate';
  class Party Candidate Winner;
  model Winner = Party*Year Candidate;
run;
*Model B4: Party Candidate*Year;
proc probit data = ElectionsFinal;
  title 'Model B4: Party Candidate*Year';
  class Party Candidate Winner;
  model Winner = Party Candidate*Year;
  *lsmeans Party Candidate*Year;
run;
*Model B5: Party Candidate;
proc probit data = ElectionsFinal;
  title 'Model B5: Party Candidate';
  class Party Candidate Winner;
  model Winner = Party Candidate;
run;



*Model B6: Party*Year;
proc probit data = ElectionsFinal;
  title 'Model B6: Party*Year';
  class Party Winner;
  model Winner = Party*Year;
run;
*Model B7: Party;
proc probit data = ElectionsFinal;
  title 'Model B7: Party';
  class Party Winner;
  model Winner (event = '1') = Party;
run;

*/

*Used model:;
proc genmod data = PartyElections descending;
  title 'GLM';
  class State PredictiveOfWinner Party;
  model PredictiveOfWinner = Party State*Party
						   /dist = bin
                           link = probit
                           lrci;
run;

*Export output data;
proc export data = PartyElections
  dbms = csv
  outfile = "\\Client\C$\Users\juanm\Dropbox\School\University of Central Florida\2017 - 2018\Spring 2018\STA 4164\Assignments\Oral Presentation\OutputData.csv";
run;