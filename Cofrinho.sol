// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Cofrinho {
    //variavel que vai guardar o endereço da carteira, pode ser lida fora do contrato
    address public dono;

    //constructor é chamado só uma vez, quando o contrato é criado
    constructor() {
        //msg.sender é sempre quem está chamando o contrato naquele momento
        //nesse caso, como estamos no constructor, o msg.sender é quem implantou o contrato
        //estamos dizendo: o dono é quem criou o contrato
        dono = msg.sender;
    }

    //função especial permite que o contrato receba ETH diretamente, sem precisar chamar nenhuma função
    //external = pq pode ser chamado de fora
    //payable = essa função pode ser receber dinheiro (ETH)
    //sem essa função o contrato não recebe dinheiro
    receive() external payable {}

    function sacar() public {
        //checagem de segurança, aqui estamos dizendo: "se quem chamou essa função não for o dono, falhha com erro"
        require(msg.sender == dono, "Apenas a dona >Vivi< pode sacar");
        //envia essa saldo para o endereço do dono // saldo do contrato em ETH
        payable(dono).transfer(address(this).balance);
    }

    function sacarParcial(uint valor) public {
        require(msg.sender == dono, "Nao eh o dono");
        require(valor <= address(this).balance, "Saldo insuficiente");
        payable(dono).transfer(valor);
    }

    //função que retorna saldo atual do contrato
    //view = só lê dados
    //returns (uint) = retorna um número (saldo em wei)
    function saldo() public view returns (uint) {
        return address(this).balance;
    }


}

//aprender o que é wei
