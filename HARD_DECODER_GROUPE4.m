function c_cor =  HARD_DECODER_GROUPE4(c,H,MAX_ITER)
M =size(H,1); % on compte le nombre de ligne dans H 
N=size(H,2); % on compte le nombre de colonnes dans H


T=zeros(M,N); % Conseil Matlab : allouer de la memoire avec des zeros afin d'eviter à matlab de deplacer les tableaux en memoire
SENT_Matrix=zeros(M,N); %preallocation


Tableau_de_decision=cell(N,1); % tableau à dimension variable pour gerer l'etape de decision( il va servir à stoker pour chaque Ci les bits candidats au vote ) 
iterator=1;

while iterator <= MAX_ITER
    
    Syndrome_matrix=mod(H*(c),2); %  Nous calculons le syndrome pour savoir si le mot code contient encore des erreurs  
    %disp('------MATRICE SYNDROME -----');     
    %disp(Syndrome_matrix);
    Syndrome_value=sum(Syndrome_matrix,1); % Nous sommons en ligne le vecteur syndrome pour connaitre le nombre d'erreurs présentes.
        
    if Syndrome_value==0  % si aucune erreur n'est présente alors la condition d'arret est validée.
        disp('CORRECT FIN');
        break        
    end
    
    
    for k=1:M
    T(k,:)=c'; % Nous créeons une matrice qui est de meme dimension que H , qui va contenir M fois le mot code à décoder !
    end
    
    for i=1:M
        for j=1:N
            if H(i,j)==0 %% La Matrice T n'a gardé que les bits qui doivent etre envoyés: Autement dit on garde tous les bits Ci qui doivent envoyer leur message au Fj correspondant
                T(i,j)=0;
            end
        end
    end  


    Parity_check=sum(T,2);% Parity check : On fait la somme des colonnes pour connaitre le nombre de 1 qu'il y a dans chaque ligne.
    %Si le resulat est pair on revoit les memes valeurs, sinon on renvoit le XOR
    
    for p=1:size(Parity_check,1)
        if mod(Parity_check(p),2)==0 % on verifie si la valeur est paire 
            SENT_Matrix(p,:)=T(p,:); % on garde le vecteur tel qu'il est ( autrement dit Fj renvoi le même message ) 
        else
            SENT_Matrix(p,:)=xor( H(p,:),T(p,:)); % on fait le XOR de ce qu'on a recu avec l'equation Fj correspondante
        end
    end  % A la sortie SENT_Matrix contient les valeurs renvoyées par chaque Fj à chaque Ci correspondant.

    
       
    
    for x=1:N
        for y=1:M
            if H(y,x)==1
                % dans cette partie on fixe une colonne et on regarde dans chaque ligne de cette colonne ou se trouvent les 1 pour connaitre les positions des valeurs qui ont été envoyées.
                %autrement dit on regarde pour chaque Ci , les nouvelles valeurs de bits reçus afin de constituer un set qui nous permettra de realiser le vote.
                Tableau_de_decision{x}=[Tableau_de_decision{x} SENT_Matrix(y,x)];
                
            end
            
        end
        Tableau_de_decision{x}=[Tableau_de_decision{x} c(x)]; % On rajoute au set de decision la valeur originale de Ci avant modification 
        
    end
    %disp(Tableau_de_decision);

    % on parcours pour chaque Ci le set de decision et on vote à la
    % majorité. En cas d'egalité , nous donnons à Ci sa valeur initilement
    % recue dans l'iteration en cours  
  
    for ligne=1:size(Tableau_de_decision,1)
        buff=Tableau_de_decision{ligne};
        if sum(buff,2)>(size(buff,2)/2) % ici on regarde si la somme des 1 pour chaque Ci depasse (taille du set/2). Si oui alors ça veut dire qu'on vote pour 1
            c(ligne)=1;
            
        elseif sum(buff,2)==(size(buff,2)/2)
            c(ligne)=buff(size(buff,2)); %on affecte au Ci sa valeur initiale
            
        else
            c(ligne)=0;
        end
    end
        
 
         
    %disp(iterator);
    iterator=iterator+1;
    
     
end

c_cor=c;


end