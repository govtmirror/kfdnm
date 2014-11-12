#' @title Simulate group data for analysis with known-fate dynamic N-mixture models
#' @description This function generates simulated data in the correct form for use in the kfdnm package
#' @export
#' 
sim_group = function(num_KF, num_years, num_surveys, recruit_rate, init_rate, 
                    annual_survival, annual_survival_KF, perfect_survey_rate, detection){
  out = matrix(NA, num_years*num_surveys, 10)
  colnames(out)=c("year","survey","num_release","num_returns","recruit","pack_surv","R","N","n","perfect")
  s.collar = annual_survival_KF^(1/num_surveys)
  s.pack = annual_survival^(1/num_surveys)
  out[,1]=rep(1:num_years, each=num_surveys)
  out[,2]=rep(1:num_surveys, num_years)
  out[,10]=rbinom(num_years*num_surveys, 1, perfect_survey_rate)
  out[,5]=0
  out[,7]=0
  out[1,3]=num_KF
  out[1,5]=rpois(1,init_rate)
  out[1,8]=out[1,5]
  for(r in 2:(num_years*num_surveys)){
    out[r,4]=rbinom(1, out[r-1,3], s.collar)
    out[r,6]=rbinom(1, out[r-1,8], s.pack)
    if(out[r,2]==1) {
      out[r,5]=rpois(1,recruit_rate)
      out[r,7] = min(3-out[r,4], out[r,6])
      out[r,3]=out[r,4] + out[r,7]
    } else {
      out[r,3]=out[r,4]
    }
    out[r,8]=out[r,5]+out[r,6]-out[r,7]
  }
  out[,9]=rbinom(n=nrow(out), size=out[,8], prob=detection)
  out[,9]=ifelse(out[,10]==1, out[,8], out[,9])
  return(as.data.frame(out))
}