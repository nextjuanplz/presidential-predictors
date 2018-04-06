/*
Oral Presentation
Juan Manuel Alzate Vanegas
STA 4164
2/23/2018
*/

/*Data on election races*/
data elections;
	*Read in data;
	infile '\\Client\E$\Users\nextjuanplz\Dropbox\School\University of Central Florida\2017 - 2018\Spring 2018\STA 4164\Assignments\Oral Presentations\cn.csv' delimiter = ',';
	input ID name $ party $ year state $ race $ district incumbentChallenger $ status $ PCCID $ PACID $;
run;
