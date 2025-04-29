// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // ou maior, se for usar OZ 5.x

import "@openzeppelin/contracts/access/Ownable.sol";

contract CofrinhoFactory is Ownable {
    struct Cofrinho {
        string nome;
        uint saldo;
    }

    mapping(address => Cofrinho[]) public cofresDoUsuario;

    event CofrinhoCriado(address dono, string nome);

    receive() external payable {}

    constructor() Ownable(msg.sender) {}

    function criarCofrinho(string memory _nome) public {
        Cofrinho memory novo = Cofrinho({
            nome: _nome,
            saldo: 0
        });

        cofresDoUsuario[msg.sender].push(novo);

        emit CofrinhoCriado(msg.sender, _nome);
    }

    function depositar(uint indice) public payable {
        require(indice < cofresDoUsuario[msg.sender].length, "Cofrinho nao encontrado");
        cofresDoUsuario[msg.sender][indice].saldo += msg.value;
    }

    function verSaldo(uint indice) public view returns (uint) {
        require(indice < cofresDoUsuario[msg.sender].length, "Cofrinho nao encontrado");
        return cofresDoUsuario[msg.sender][indice].saldo;
    }

    function verNome(uint indice) public view returns (string memory) {
        require(indice < cofresDoUsuario[msg.sender].length, "Cofrinho nao encontrado");
        return cofresDoUsuario[msg.sender][indice].nome;
    }

    function sacar(address usuario, uint indice) public onlyOwner {
        require(indice < cofresDoUsuario[usuario].length, "Cofrinho nao encontrado");

        uint valor = cofresDoUsuario[usuario][indice].saldo;
        require(valor > 0, "Saldo zerado");

        cofresDoUsuario[usuario][indice].saldo = 0;

        payable(owner()).transfer(valor);
    }
}
