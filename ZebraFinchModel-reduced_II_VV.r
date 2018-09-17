###initial pop conditions
timesteps <- 200 #length of simulation

##parameters
bn <- 1    ##avg broodsize of adult with non-adaptive behavior
ba <- 2*bn ##avg broodsize of adult with adaptive behavior. ba > bn
p_as <- 0.2  #prob an adapted adult produces stressed offspring
p_ns <- 0.8  #prob an nonadapted adult produces stressed offspring
s <- 0.5	#prob individual learner succesfully acquires adaptive behavior
U <- 0.1  #prob environment changes states
mu_s <- 0.1	#mortality rate of social learners
mu_i <- 0.11 #mortality rate of individual learners
mu_n <- 1 # excess mortality factor of non-adapted individuals (to be added at some point?)

#create bins to store recursion values for each type
n_VVJH <- rep(0,timesteps + 1)
n_VVJS <- rep(0,timesteps + 1)
n_IIJH <- rep(0,timesteps + 1)
n_IIJS <- rep(0,timesteps + 1)

n_VVAa <- rep(0,timesteps + 1)
n_VVAn <- rep(0,timesteps + 1)
n_IIAa <- rep(0,timesteps + 1)
n_IIAn <- rep(0,timesteps + 1)

n_Aa <- rep(0,timesteps + 1)
n_An <- rep(0,timesteps + 1)
N <- rep(0,timesteps + 1)
u <- rep(0,timesteps + 1)
fa <- rep(0,timesteps + 1)
fn <- rep(0,timesteps + 1)

N0 <- 200
n_VVAa[1] <- N0/4
n_VVAn[1] <- N0/4
n_IIAa[1] <- N0/4
n_IIAn[1] <- N0/4
n_An[1] <- n_VVAn[1] + n_IIAn[1]
n_Aa[1] <- n_VVAa[1] + n_IIAa[1]

n_VVJH[1] <- (N0/4)*ba*(1-p_as) + (N0/4)*bn*(1-p_ns)
n_VVJS[1] <- (N0/4)*ba*p_as + (N0/4)*bn*p_ns
n_IIJH[1] <- (N0/4)*ba*(1-p_as) + (N0/4)*bn*(1-p_ns)
n_IIJS[1] <- (N0/4)*ba*p_as + (N0/4)*bn*p_ns

u[1] <- 0
N[1] <- n_VVAa[1] + n_VVAn[1] + n_IIAa[1] + n_IIAn[1] + n_VVJH[1] + n_VVJS[1] + n_IIJH[1] + n_IIJS[1]
fa[1]<- (n_Aa[1]*ba)/(n_Aa[1]*ba + n_An[1]*bn)
fn[1]<- (n_An[1]*bn)/(n_Aa[1]*ba + n_An[1]*bn)

#recursions
for (t in 1:timesteps)
{
    # juvenile recruitment
    n_VVJH[t+1] <- (n_VVAa[t])*ba*(1-p_as) + (n_VVAn[t])*bn*(1-p_ns)
    n_VVJS[t+1] <- (n_VVAa[t])*ba*p_as + (n_VVAn[t])*bn*p_ns
    n_IIJH[t+1] <- (n_IIAa[t])*ba*(1-p_as) + (n_IIAn[t])*bn*(1-p_ns)
    n_IIJS[t+1] <- (n_IIAa[t])*ba*p_as + (n_IIAn[t])*bn*p_ns
    
    #adult recruitment
    n_VVAa[t+1] <- (n_VVJS[t] + n_VVJH[t])*(1-u[t])*fa[t]*(1-mu_s)
    n_VVAn[t+1] <- (n_VVJS[t] + n_VVJH[t])*((1-u[t])*fn[t] + u[t])*(1-mu_s*mu_n)
    n_IIAa[t+1] <- (n_IIJS[t] + n_IIJH[t])*s*(1-mu_i)
    n_IIAn[t+1] <- (n_IIJS[t] + n_IIJH[t])*(1-s)*(1-mu_i*mu_n)
    
    n_Aa[t+1] <- n_VVAa[t+1] + n_IIAa[t+1]
    n_An[t+1] <- n_VVAn[t+1] + n_IIAn[t+1]
    N[t+1] <- n_VVAa[t+1] + n_VVAn[t+1] + n_IIAa[t+1] + n_IIAn[t+1] + n_VVJH[t+1] + n_VVJS[t+1] + n_IIJH[t+1] + n_IIJS[t+1]
    u[t+1] <- rbinom(n=1,prob=U,size=1) #sample environment changing
    fa[t+1]<- (n_Aa[t+1]*ba)/(n_Aa[t+1]*ba + n_An[t+1]*bn)
    fn[t+1]<- (n_An[t+1]*bn)/(n_Aa[t+1]*ba + n_An[t+1]*bn)
}

# compute proportions of each strategy for summary plot
p_V <- ( n_VVJH + n_VVJS + n_VVAa + n_VVAn ) / N
p_I <- ( n_IIJH + n_IIJS + n_IIAa + n_IIAn ) / N
q_V <- ( n_VVAa ) / ( n_VVAa + n_VVAn )
q_I <- n_IIAa / ( n_IIAa + n_IIAn )

plot( p_V , ylim=c(0,1) , type="l" )
lines( 1:length(p_I) , p_I , col="red" )
lines( 1:length(q_V) , q_V , lty=2 )
lines( 1:length(q_I) , q_I , lty=2 , col="red" )

# age structure
p_JV <- ( n_VVJS + n_VVJH ) / ( n_VVJH + n_VVJS + n_VVAa + n_VVAn )
p_AV <- ( n_VVAa + n_VVAn ) / ( n_VVJH + n_VVJS + n_VVAa + n_VVAn )
plot( p_JV , ylim=c(0,1) , type="l" )

p_JI <- ( n_IIJS + n_IIJH ) / ( n_IIJH + n_IIJS + n_IIAa + n_IIAn )
p_AI <- ( n_IIAa + n_IIAn ) / ( n_IIJH + n_IIJS + n_IIAa + n_IIAn )
plot( p_JI , ylim=c(0,1) , type="l" )
