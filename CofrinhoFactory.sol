//Qualquer pessoa pode criar o seu próprio cofrinho dando um nome a ele          
//O contrato vai manter um registro de todos os cofrinhos, associando dono, nome e saldo.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CofrinhoFactory {
    //Define o formato do cofrinho
    struct Cofrinho {
        string nome;
        uint saldo;
    }

    // Cada endereço pode ter vários cofrinhos
    mapping(address => Cofrinho[]) public cofresDoUsuario;

    //Evento para monitorar criação de cofrinhos
    event CofrinhoCriado(address dono, string nome);

    receive() external payable {}

    //Qualquer pessoa pode criar seu cofrinho
    function criarCofrinho(string memory _nome) public {
        Cofrinho memory novo = Cofrinho({
            nome: _nome,
            saldo: 0
        });

        //Salva no mapping daquele msg.sender
        cofresDoUsuario[msg.sender].push(novo);

        //Dispara o evento CofrinhoCriado
        emit CofrinhoCriado(msg.sender, _nome);
    }

    modifier somenteDono(uint indice) {
        //cofresDoUsuario[msg.sender] é uma lista (array) de cofrinhos da pessoa que está chamando a função msg.sender
        //Verificação de segurança para garantir que o índice realmente existe no array.
        require(indice < cofresDoUsuario[msg.sender].length, "Cofrinho nao encontrado");
        _;
    }

    //Adiciona saldo em um cofrinho especificio do usuário
    function depositar(uint indice) public somenteDono(indice) payable {
        cofresDoUsuario[msg.sender][indice].saldo += msg.value;
    }

    //Consulta saldo de um cofrinho do usuário
    function verSaldo(uint indice) public somenteDono(indice) view returns (uint) {
        return cofresDoUsuario[msg.sender][indice].saldo;
    }

    //Consulta nome de um cofrinho do usuario
    function verNome(uint indice) public somenteDono(indice) view returns (string memory) {
        return cofresDoUsuario[msg.sender][indice].nome;
    }

    //Saca todo o valor de um cofrinho
    //indice representa qual cofrinho da lista deseja sacar
    function sacar(uint indice) public somenteDono(indice) {
        //retirado pois o modifier soDono faz isso 
        //require(indice < cofresDoUsuario[msg.sender].length, "Cofrinho nao encontrado");

        uint valor = cofresDoUsuario[msg.sender][indice].saldo;
        //Verifica se tem algo no cofrinho, se tiver mostra a mensagem
        require(valor >  0, "Saldo zerado" );

        //Antes de transferir o valor, o saldo do cofrinho é zerado
        //Isso evita ataques do tipo “reentrância” (um bug de segurança clássico)
        cofresDoUsuario[msg.sender][indice].saldo = 0;

        //Envia o valor guardado para a carteira da pessoa que chamou a função
        //Só conseguimos usar .transfer() porque o msg.sender é convertido para payable
        payable(msg.sender).transfer(valor);
    }
}

//As linhas do código são executadas em ordem, mas a transação só é finalizada (ou revertida) se tudo der certo até o final.