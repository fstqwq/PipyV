#include "io.h"
#include<string.h>
#define SMAX 2001
#define CI(a) ((a)-'a')
#define FZW
char str[SMAX];
int height[SMAX];
int rank[SMAX];
int sz1[SMAX];
int sz2[SMAX];
int num[SMAX];
int sa[SMAX];
int*temp;
int xian;
int len;
int tot;
int f1;
int f2;
int f3;
int*x;
int*y;
int main()
{
	memset(sz1,-1,sizeof(sz1));
	memset(sz2,-1,sizeof(sz2));
        getstr(str);
	//scanf("%s",str);
	xian=26;
	len=strlen(str);
	x=sz1;
	y=sz2;
	for(f1=0;f1<xian;f1++)
		num[f1]=0;
	for(f1=0;f1<len;f1++)
	{
		x[f1]=CI(str[f1]);
		num[x[f1]]++;
	}
	for(f1=1;f1<xian;f1++)
		num[f1]+=num[f1-1];
	for(f1=len-1;f1>=0;f1--)
		sa[--num[x[f1]]]=f1;
	for(f1=1;f1<=len;f1<<=1)
	{
		for(tot=0,f2=len-f1;f2<len;f2++)
			y[tot++]=f2;
		for(f2=0;f2<len;f2++)
			if(sa[f2]>=f1)
				y[tot++]=sa[f2]-f1;
		for(f2=0;f2<xian;f2++)
			num[f2]=0;
		for(f2=0;f2<len;f2++)
			num[x[y[f2]]]++;
		for(f2=1;f2<xian;f2++)
			num[f2]+=num[f2-1];
		for(f2=len-1;f2>=0;f2--)
			sa[--num[x[y[f2]]]]=y[f2];
		temp=x;
		x=y;
		y=temp;
		for(tot=1,x[sa[0]]=0,f2=1;f2<len;f2++)
			if((y[sa[f2-1]]==y[sa[f2]])&&(y[sa[f2-1]+f1]==y[sa[f2]+f1]))
				x[sa[f2]]=tot-1;
			else
				x[sa[f2]]=tot++;
		if(tot>=len)
			break;
		xian=tot;
	}
	for(f1=0;f1<len;f1++)
		rank[sa[f1]]=f1;
	for(f2=0,f1=0;f1<len;f1++)
	{
		if(f2>0)
			f2--;
		if(rank[f1]==0)
			continue;
		for(f3=sa[rank[f1]-1];str[f1+f2]==str[f3+f2];f2++)
			continue;
		height[rank[f1]]=f2;
	}

	for(f1=0;f1<len;f1++)
          outl(sa[f1]+1), outb(' '), sleep(5);
	outb('\n');
	for(f1=1;f1<len;f1++)
          outl(height[f1]), outb(' '), sleep(5);
        outb('\n');
	return 0;
}
