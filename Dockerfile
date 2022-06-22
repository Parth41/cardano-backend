FROM haskell

RUN apt update && apt install git
RUN git --version
RUN cabal update
RUN git clone https://github.com/Parth41/cardano-backend.git    
RUN bash -c 'cd cardano-backend/executor && cabal run'