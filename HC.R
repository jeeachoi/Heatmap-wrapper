# Input:
# [FileNameIn] [Whether cluster by rows T/F] [Whether cluster by columns T/F] [Whether scale data within a row T/F] 
# [Lower limit of detection] [ Need normalization or not ] [OutputName] [bottom margin] [right margin]
# [pdf height] [pdf width] [whether active X11]

library(gplots)
options=commandArgs(trailingOnly = TRUE)
print(options)
File=options[1] # file name
Rowhc=as.logical(options[2])
Colhc=as.logical(options[3])
Scale=as.logical(options[4])
LOD=as.numeric(options[5]) # lower limit of detection
Norm=as.logical(options[6]) # whether perform normalization; if "T" is specified, median-by-ratio normalization will be performed.
Out=options[7]
Margin1=as.numeric(options[9]) # margin - bottom
Margin2=as.numeric(options[10]) # margin - right
Height=as.numeric(options[11]) # pdf height
Width=as.numeric(options[12]) # pdf width
Plot=options[8] # whether plot

if(length(options)<7)Out=NULL
if(length(options)<9)Margin1=7
if(length(options)<10)Margin2=7
if(length(options)<11) Height=NULL
if(length(options)<12) Width=NULL
if(length(options)<8)Plot="T"

if(Plot=="T") X11()

# csv or txt
tmp=strsplit(File, split="\\.")[[1]]
FileType=tmp[length(tmp)]

if(FileType=="csv"){
	cat("\n Read in csv file \n")
	prefix=strsplit(File,split="\\.csv")[[1]][1]
	In=read.csv(File,stringsAsFactors=F,row.names=1)
}
if(FileType!="csv"){
	cat("\n Read in tab delimited file \n")
	prefix=strsplit(File,split=paste0("\\.",FileType))[[1]][1]
	In=read.table(File,stringsAsFactors=F, sep="\t",header=T,row.names=1,quote="\"")
}



Matraw=data.matrix(In)

Max=apply(Matraw,1,max)
WhichRM=which(Max<LOD)
print(paste(length(WhichRM),"genes with max expression < ", LOD, "are removed"))

Mat=Matraw
if(length(WhichRM)>0)Mat=Matraw[-WhichRM,]
print(str(Mat))

if(Norm){
cat("\n ==== Performing normalization ==== \n")
library(EBSeq)
Sizes=MedianNorm(Mat)
if(is.na(Sizes[1]))cat("\n Warning: all genes have 0(s), normalization is not performed \n")
else Mat=GetNormalizedMat(Mat, MedianNorm(Mat))
}

sc="none"
if(Scale)sc="row"

Nrow=nrow(Mat)
Ncol=ncol(Mat)
if(is.null(Height)) Height=max(Nrow/5,4)+Margin1-7
if(is.null(Width)) Width=max(Ncol/4,4)+Margin2-7

if(!is.null(Out))pdf(Out,width=Width,height=Height)
if(Plot=="T" | (!is.null(Out)))tmp=heatmap.2(Mat,trace="none",Rowv=Rowhc,
			Colv=Colhc,scale=sc,#keysize=max(4/Nrow,.5),
				col=greenred,margins=c(Margin1,Margin2))
if(!is.null(Out))dev.off()

if(is.null(Out) & Plot=="T")Sys.sleep(1e30)


