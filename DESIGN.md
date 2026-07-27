# CompuMar Core - Decisiones de Diseño y Consenso

## Principio de Consenso Activo

> "CompuMar opera de forma permanente en reglas de consenso v7 (CryptoNight v1), por decisión de diseño orientada a minería web/CPU de bajo consumo. RandomX y versiones posteriores no se activan intencionalmente."

### Justificación Técnica de la Arquitectura

* **Anclaje Operativo en v7:** El motor se mantiene fijo en la versión 7 para garantizar una experiencia de minería web fluida, accesible y sin los requisitos de memoria masivos de las épocas posteriores.
* **Preservación Intencional de Entradas (v8 a v15):** Las entradas de hard forks subsiguientes en la tabla del código fuente **se mantienen de forma deliberada**. No son código basura ni un descuido: sirven como referencia estructural estática y herencia de la base de código original, mientras que la lógica de validación restringe de forma efectiva el avance del protocolo a la versión 7.
* **Compatibilidad del Ecosistema:** Las estructuras heredadas se conservan intactas para evitar roturas en los scripts de compilación de C++, asegurando que la gobernanza operativa de la red descanse soberanamente sobre el protocolo base v7.
