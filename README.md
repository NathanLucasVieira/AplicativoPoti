P.O.T.I - Alimentador Pet Inteligente (IoT)
📖 Sobre o Projeto
O P.O.T.I (Alimentador Pet Inteligente) nasceu da necessidade de aprimorar o cuidado com a alimentação de animais de estimação. Em um país com mais de 160 milhões de pets e um mercado em constante crescimento, muitos tutores enfrentam dificuldades para manter uma rotina alimentar regular para seus companheiros, seja pela rotina de trabalho ou por viagens.


A alimentação inadequada pode levar a diversos problemas de saúde, como obesidade, distúrbios digestivos e ansiedade. Pensando nisso, o P.O.T.I foi desenvolvido como uma solução tecnológica para automatizar e gerenciar a dieta dos pets de forma prática, precisa e remota, garantindo mais saúde para eles e tranquilidade para seus tutores.


Este projeto é um Trabalho de Graduação do curso Superior de Tecnologia em Análises e Desenvolvimento de Sistemas da FATEC Itapetininga.



✨ Funcionalidades Principais
O sistema oferece controle total sobre a alimentação do pet, acessível de qualquer lugar através de um Web App intuitivo.


Controle Remoto via Web App: Gerencie a alimentação do seu pet de onde estiver.


Agendamento de Refeições: Programe rotinas de alimentação com horários e porções personalizadas para as necessidades do seu animal.

Alimentação Manual: Libere uma porção de ração de forma instantânea através do aplicativo.


Dosagem Precisa: O sistema utiliza uma hélice rotativa de 6 pás, acionada por um servo motor, para garantir a dosagem exata da ração em cada refeição.



Monitoramento do Nível de Ração: Um sensor ultrassônico na tampa do reservatório mede a quantidade de ração disponível e envia notificações ao tutor quando o nível está baixo.




Histórico de Alimentação: Acesse um registro detalhado com datas e horários em que o pet foi alimentado.


Backup de Energia: O alimentador conta com um sistema de baterias 18650 para garantir seu funcionamento mesmo durante quedas de energia.


🛠️ Tecnologias e Materiais
O projeto integra hardware e software para criar uma solução completa e funcional.

Hardware
Componente	Modelo	Funcionalidade
Microcontrolador	ESP32-S3-WROOM-1	
Cérebro do projeto, responsável por controlar os componentes e pela conectividade Wi-Fi.

Sensor de Nível	Ultrassônico HC-SR04	
Mede a distância até a ração para calcular o volume no reservatório.

Atuador	Micro Servo Motor MG90S	
Gira a hélice para liberar a ração com precisão.

Fonte Principal	Fonte 12V 4A	
Fornece energia estável para todo o sistema.

Backup de Energia	3x Baterias 18650 em série	
Garante o funcionamento contínuo em caso de falta de energia.

Regulador de Tensão	Step-down LM2596	
Ajusta a tensão de 12V para alimentar o ESP32 e outros módulos com segurança.


Software

Firmware (ESP32): Programado em C/C++ via Arduino IDE.


Web App (Frontend): Desenvolvido com HTML, CSS e JavaScript.



Backend: Construído com PHP e o framework Laravel.



Banco de Dados: Firebase



Comunicação: Protocolo HTTP para a troca de dados entre o ESP32 e o servidor.


Materiais da Estrutura

Peças Impressas em 3D: Utiliza PETG, um material resistente, seguro para contato indireto com alimentos e com boa durabilidade.



Reservatório: Construído em PVC de 6 polegadas (15,24 cm de diâmetro), um material de baixo custo, leve e resistente.



🏗️ Design e Protótipo
Toda a estrutura do alimentador foi modelada em software 3D, garantindo um encaixe preciso e funcional dos componentes.


Peça	Dimensões (Aproximadas)	Detalhes
Reservatório	19.30 cm (altura) x 15.24 cm (diâmetro)	
Capacidade para 3,52 litros de ração.

Hélice Rotativa	8.92 cm x 8.92 cm	
Libera aproximadamente 13,33g de ração por pá.


Estrutura Completa	35 cm (altura total)	
Design compacto e funcional.


Estrutura Explodida
Protótipo do Web App (Mobile)
O design do aplicativo foi pensado para ser limpo, moderno e de fácil utilização.

🚀 Status do Projeto
Em desenvolvimento... Esse projeto é so uma versão do final

O projeto segue a metodologia de desenvolvimento dividida em etapas, encontrando-se atualmente na fase 

Gamma, focada no desenvolvimento e montagem do protótipo físico e testes de integração entre hardware e software.

👥 Autores
Luiz Guilherme de Queiroz Soares

Marcos Siqueira Santos

Nathan Lucas de Paula Vieira

