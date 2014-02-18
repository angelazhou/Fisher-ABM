


############## Run until encounter rates are stationary #############
function make_equilibrium(fish,con,tau,var,SN)
while max(tau.dmu) > 0.01
    ## Distances
    D,Dx,Dy = fnc_distance(fish.xy,con.xy);

    ## Information sharing
    for i = 1:P.C_n

        ## gather information
        #  Dmin: distance to nearest fish
        #  DDx,DDy: components of raw direction vector
        #  JJ: index of nearest fish
        (var.Dmin[i],var.DDx[i],var.DDy[i],var.JJ[i]) = fnc_information(D,Dx,Dy,SN,i);

        ## direction
        #  ANG: direction vector
        #  VR:  travel speed (a function of Dmin)
        #  KK:  1/0; 1 if fish is caught, 0 if nothing caught
        (var.ANG[i],var.VR[i],var.KK[i]) =
            fnc_direction(var.Dmin[i],var.DDx[i],var.DDy[i],var.ANG[i]);

        ## harvest
        (con.H[i], fish.xy,
        tau.n[i],tau.s[i],tau.t[i],tau.dmu[i],tau.mu[i]) =
                fnc_harvest_e(var.KK[i],var.JJ[i],con.H[i],
                    fish.xy,fish.ci,fish.cl,
                    tau.n[i],tau.s[i],tau.t[i],tau.dmu[i],tau.mu[i]);

     end

    ## Move
    (fish.cl[:,1],fish.cl[:,2],con.xy[:,1],con.xy[:,2]) =
        fnc_move(fish.cl,con.xy,var.ANG,var.VR);

    ## Relocate fish (simulates movement)
    fish.xy = fnc_relocate(fish.cl,fish.xy);
end
return
end

############## Run for a fixed length of time #############
function make_season(fish_xy,cons_xy,cons_H,SN)
    for t = 1:P_Tend-1
        ## Distances
        D,Dx,Dy = fnc_distance(fish_xy[:,:,t],cons_xy[:,:,t]);

        ## Information sharing
        for i = 1:P_C_n

            ## gather information
            #  Dmin: distance to nearest fish
            #  DDx,DDy: components of raw direction vector
            #  JJ: index of nearest fish
            (Dmin[i], DDx[i], DDy[i], JJ[i]) = fnc_information(D,Dx,Dy,SN,i);

            (dmin1,ddx1,ddy1,jj1) = fnc_information(D,Dx,Dy,ones(P_C_n,P_C_n),i);
            (dmin2,ddx2,ddy2,jj2) = fnc_information(D,Dx,Dy,eye(P_C_n),i);

            ## direction
            #  ANG: direction vector
            #  VR:  travel speed (a function of Dmin)
            #  KK:  1/0; 1 if fish is caught, 0 if nothing caught
            (ANG[i], VR[i],KK[i]) =
                fnc_direction(Dmin[i],DDx[i],DDy[i],ANG[i]);

            ## harvest
            (cons_H[i,t], fish_xy[:,:,t]) =
                    fnc_harvest_s(KK[i],JJ[i],cons_H[i,t],
                        fish_xy[:,:,t],fish_cl,fclust_xy[:,:,t]);
         end

        ## Move
        (fclust_xy[:,1,t+1],fclust_xy[:,2,t+1],cons_xy[:,1,t+1],cons_xy[:,2,t+1]) =
            fnc_move(fclust_xy[:,:,t],cons_xy[:,:,t],ANG,VR);

        ## Relocate fish (simulates movement)
        fish_xy[:,:,t+1] = fnc_relocate(fclust_xy[:,:,t],fish_xy[:,:,t]);
    end
    return fish_xy,cons_xy,cons_H;
end



