function c_cor =  SOFT_DECODER_GROUPE4(c,H,p,MAX_ITER)
Codeword=c'; 


M =size(H,1); % on compte le nombre de ligne dans H 
N=size(H,2); % on comptele nombre de colonnes dans H


Q_1=zeros(M,N);% Conseil Matlab : allouer de la memoire avec des zeros afin d'eviter à matlab de deplacer les tableaux en memoire
R_0=zeros(M,N);
Kij=zeros(M,N); 
Ki=zeros(1,N);

PRES_0=zeros(M,N); % ces tableaux sont des tableaux de calculs intermédiaires
PRES_1=zeros(M,N);
TEMP_0=zeros(1,N);
TEMP_1=zeros(1,N);

Q_decision_0=zeros(1,N); % Matrices de decision
Q_decision_1=zeros(1,N);


Pi_1=p'; % je crée le vecteur des Pi(1)
Pi_0=1-Pi_1; %Création du vecteur Pi(0)=1-Pi(1)

for k=1:M
    Q_1(k,:)=Pi_1; % je cree une matrice qui est de meme dimension que H , qui va contenir M fois le mot code à décoder !
end

Q_0=ones(M,N)-Q_1;
iterator=1;

while iterator <= MAX_ITER  %première condition d'arret 


    Syndrome_matrix=mod(H*(Codeword'),2); %  Nous calculons le syndrome pour savoir si le mot code contient encore des erreurs
    Syndrome_value=sum(Syndrome_matrix,1); % Nous sommons en ligne le vecteur syndrome pour connaitre le nombre d'erreurs présentes.
    %disp('syndrome value :');
    %disp(Syndrome_value);
    if Syndrome_value==0  % si aucune erreur n'est présente alors la condition d'arret est validée.
        disp('CORRECT FIN');
        break           
    end
    
    
    
   
    for i=1:M
        for j=1:N
            if H(i,j)==0  % on cree la matrice des Qij(0) et des Qij(1) et nous mettons à 0 les probabilités des indices (i,j) qui ne correspondent à aucun lien entre un Ci et un Fj.
                          %%% autrement dit, à chaque fois qu'il y a un 1 dans la matrice H alors cela signifie qu'il y a un lien entre le Ci et le Fj correspondant donc on ne modifie pas la probabilité 
                Q_1(i,j)=0;
                Q_0(i,j)=0;
            end
        end
    end %% La Matrice T n'a gardé que les probabilites qui doivent etre envoyées 
    
    
    
       
    %%%%%%%%%%%%%Dans cette partie nous procedons au calcul des rji(0) comme indiqué    dans le document
    for ligne=1:M
        for colonne=1:N
            R_0(ligne,colonne)=0.5;
            for s=colonne:(colonne+N-2) % afin d'avoir N-1 termes dans le produit
                R_0(ligne,colonne)=R_0(ligne,colonne)*(1-2*Q_1(ligne,mod(s,N)+1)); %implementation d'un modulo pour pouvoir circuler dans le buffer en evitant la valeur privée 
                % Lors de ce calcul nous allons faire intervenir les 
                % valeurs contenues à des indices Qij(1) qui ne nous interessent pas mais commes ces valeurs ont été mises à zéros précedemment alors elles n'influencent pas les resultats
            
            end
            R_0(ligne,colonne)=R_0(ligne,colonne)+0.5;
        end
    end
    
    R_1=ones(M,N)-R_0;
    
    
        
    %%%Dans cette partie on vient changer les valeurs des probabilité qui ne
    %representent aucun lien entre les Ci et le Fj. Sauf que dans ce cas
    %precis on ne va pas les fixer à 0. Etant donné la formule de calcul
    %des Qij, afin que ces valeurs n'interfèrent pas , on fixe ces
    %probabilité à 1. Car dans le produit, multiplier par 1 n'a aucune
    %influence 
    for i=1:M
        for j=1:N
            if H(i,j)==0 
                R_1(i,j)=1;
                R_0(i,j)=1;
            end
        end
    end % on vient d'enlever les valeurs inutiles quand les tableaux des Rji(0) et Rji(1)
    
    
    
    
    
    %Dans cette partie on met à jour les nouvelles valeurs des Qij(0) et
    %Qij(1) en appliquant la formule . Pour ce calcul, a chaque itération on va fixer une
    %colonne et parcourir les lignes 
    for column=1:N
        for row=1:M
            PRES_0(row,column)=Pi_0(column);
            PRES_1(row,column)=Pi_1(column);
            for s=row:(row+M-2) %pour avoir un produit de seulement M-1 termes
                PRES_0(row,column)=PRES_0(row,column)*R_0(ligne,mod(s,M)+1); %on retrouve le modulo pour prendre en compte toutes les valeurs des indices sauf celui privé. Cela nous permet d'avoir une sorte de buffer circulaire.
                PRES_1(row,column)=PRES_1(row,column)*R_1(ligne,mod(s,M)+1);
            end
            Kij(row,column)=1/(PRES_0(row,column)+PRES_1(row,column)); % calcul du Kij de telle sorte que Qij(0)+Qij(1)=1
            Q_0(row,column)=Kij(row,column)*PRES_0(row,column);
            Q_1(row,column)=Kij(row,column)*PRES_1(row,column);
        end
    end
    % Les valeurs valeurs des Qij ont été mises à jour et serviront à la
    % prochaine itération
    
    
    
    %Dans cette partie on calcule les probabilites de décision Qi(0) et Qi(1)
    %et on effectue le test de decison ensuite nous modifions les bits du
    %mot code en question 
    for column=1:N
        TEMP_0(column)=Pi_0(column);
        TEMP_1(column)=Pi_1(column);
        for row=1:M
            TEMP_0(column)=TEMP_0(column)*R_0(row,column);
            TEMP_1(column)=TEMP_1(column)*R_1(row,column);
        end
        Ki(column)=1/(TEMP_0(column)+TEMP_1(column)); %Ki est calculé de telle sorte que Qi(0)+Qi(1)=0
        Q_decision_0(column)=Ki(column)*TEMP_0(column);
        Q_decision_1(column)=Ki(column)*TEMP_1(column);
        
        if Q_decision_1(column)>Q_decision_0(column) %etape de decision 
            Codeword(column)=1;
        else
            Codeword(column)=0;
        end
        
    end
    %disp(iterator);
    iterator=iterator+1;
    
        
            
    
    
    
end

c_cor=Codeword'; 


end