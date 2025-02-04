library(dplyr)
library(ggplot2)
library(ggpubr)

result=read.csv("./diffPeaks.csv")
DAG <- result %>% 
  filter(RPM.IP.Control>1,RPM.input.Control>1) %>%
  filter(!is.na(RPM.IP.Control),!is.na(fdr)) %>%
  mutate(RPM.IP.Control.log10=log10(RPM.IP.Control),
         RPM.input.Control.log10=log10(RPM.input.Control))

DAG$enrichment=DAG$RPM.IP.Control/DAG$RPM.input.Control

DAG$Sig="none"
DAG$Sig[which((DAG$diff.log2FC)> 1.5 & (DAG$fdr<0.01))]='up'
DAG$Sig[which((DAG$diff.log2FC< -1.5) & (DAG$fdr<0.01))]='down'
table(DAG$Sig)
# down  none    up 
# 12765 15645  4213

################################  RPM.IP.Control.log10
library(ggthemes)
library(ggrepel)

ggscatter(DAG,y = 'diff.log2FC',x = "RPM.IP.Control.log10",
          color="Sig",
          palette = c("#2878B5","grey","#BB9727"),
          label = DAG$label,
          repel = T,
          ylab = "log2FC(shMETTL3/shCTRL)",
          xlab="nucleolar meRIP-seq [Log10(RPM)] in shCTRL",
          size = 1) + 
  theme_base()+
  theme(panel.border = element_blank(), 
        axis.line = element_line(color = "black", size = 0.5),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        legend.position = "none", 
        plot.background = element_blank(), 
        panel.background = element_blank(), 
        axis.ticks = element_blank()) + 
  scale_x_continuous(limits=c(0,6),breaks = c(0,2,4,6),
                     minor_breaks = NULL,expand = c(0, 0),)+
  scale_y_continuous(limits = c(-10,10),breaks = c(-10,-5,-1.5,1.5,5,10))+
  geom_hline(yintercept = c(-1.5,1.5),linetype = "dashed")+
  geom_text_repel(data = filter(DAG, geneID %in% c("RN7SK")),
                  aes(label = geneID),
                  size = 2, 
                  color = 'black')
write.table(DAG,file="DAG.txt",sep="\t",row.names = F,col.names = T,quote = F)
