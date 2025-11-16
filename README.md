# Vitrine Virtual - Sistema de Agendamentos White-Label Multi-Tenant

Sistema completo de agendamentos desenvolvido em Flutter com arquitetura Clean Architecture, Firebase e suporte multi-tenant.

## Características Principais

- **Multi-Tenant**: Suporte para múltiplos clientes com subdomínios personalizados
- **White-Label**: Personalização completa de cores, logo e fontes por tenant
- **Clean Architecture**: Separação clara de responsabilidades em camadas
- **State Management**: Cubit (flutter_bloc) para gerenciamento de estado
- **Firebase**: Backend completo com Firestore
- **Responsivo**: Suporte para web, mobile e tablet

## Estrutura do Projeto

```
lib/
├── core/               # Funcionalidades compartilhadas
├── data/               # Camada de dados (models, repositories, datasources)
├── domain/             # Lógica de negócio (usecases)
├── presentation/       # UI (screens, widgets, cubits)
├── routes/             # Navegação
└── main.dart           # Ponto de entrada
```

## Configuração

### 1. Instalar Dependências

```bash
flutter pub get
```

### 2. Configurar Firebase

Crie um projeto no [Firebase Console](https://console.firebase.google.com/) e:

1. Adicione um app Web ao projeto
2. Copie as credenciais do Firebase
3. Substitua os valores em `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'SUA_API_KEY',
    appId: 'SEU_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_STORAGE_BUCKET',
  ),
);
```

### 3. Configurar Firestore

Crie as seguintes collections no Firestore:

#### Collection: `tenants`
```json
{
  "subdomain": "barbearia-joao",
  "name": "Barbearia do João",
  "logo_url": "https://example.com/logo.png",
  "whatsapp": "+5511999999999",
  "theme_settings": {
    "primary_color": "#2196F3",
    "secondary_color": "#FF9800",
    "font_family": "Roboto"
  }
}
```

#### Collection: `services`
```json
{
  "tenant_id": "TENANT_ID",
  "name": "Corte de Cabelo",
  "description": "Corte moderno com máquina e tesoura",
  "duration_minutes": 30,
  "price": 50.00,
  "image_url": "https://example.com/service.jpg",
  "is_active": true,
  "created_at": "TIMESTAMP"
}
```

#### Collection: `availability`
```json
{
  "tenant_id": "TENANT_ID",
  "day_of_week": 1,
  "start_time": "09:00",
  "end_time": "18:00",
  "slot_duration_minutes": 30
}
```

#### Collection: `bookings`
```json
{
  "tenant_id": "TENANT_ID",
  "service_id": "SERVICE_ID",
  "customer_name": "João Silva",
  "customer_phone": "+5511999999999",
  "booking_date": "TIMESTAMP",
  "booking_time": "14:00",
  "status": "pending",
  "created_at": "TIMESTAMP"
}
```

### 4. Executar o Projeto

Para desenvolvimento local:

```bash
flutter run -d chrome --web-port=8080
```

Para simular subdomínios localmente, adicione ao `/etc/hosts`:

```
127.0.0.1 demo.localhost
127.0.0.1 barbearia-joao.localhost
```

Acesse: `http://demo.localhost:8080`

## Funcionalidades Implementadas

### Tenant (Cliente do Sistema)
- ✅ Carregamento de configurações por subdomínio
- ✅ Personalização de tema (cores e fontes)
- ✅ Logo customizável
- ✅ Número de WhatsApp para confirmação

### Serviços
- ✅ Listagem de serviços do tenant
- ✅ Detalhes do serviço com imagem, descrição, duração e preço
- ✅ Grid responsivo (1-3 colunas)

### Agendamento
- ✅ Seleção de data (calendário)
- ✅ Horários disponíveis baseados em availability
- ✅ Validação de disponibilidade em tempo real
- ✅ Formulário de dados do cliente com validação
- ✅ Formatação automática de telefone brasileiro

### Confirmação
- ✅ Resumo do agendamento
- ✅ Redirecionamento para WhatsApp com mensagem pré-formatada
- ✅ Navegação para home

## Princípios e Padrões

### SOLID
- **S**ingle Responsibility: Cada classe tem uma única responsabilidade
- **O**pen/Closed: Código aberto para extensão, fechado para modificação
- **L**iskov Substitution: Implementações respeitam contratos
- **I**nterface Segregation: Interfaces específicas e coesas
- **D**ependency Inversion: Dependência de abstrações, não de implementações

### Clean Architecture
- **Domain**: Entidades e casos de uso (regras de negócio)
- **Data**: Implementações de acesso a dados
- **Presentation**: UI e gerenciamento de estado

### Validações
- Nomes: mínimo 3 caracteres
- Telefone: formato brasileiro (+55 XX XXXXX-XXXX)
- Datas: não permite datas passadas
- Horários: verifica disponibilidade no Firestore

## Dependências Principais

```yaml
firebase_core: ^3.6.0          # Firebase Core
cloud_firestore: ^5.4.4        # Database
flutter_bloc: ^8.1.6           # State Management
equatable: ^2.0.5              # Value equality
dartz: ^0.10.1                 # Functional programming
intl: ^0.19.0                  # Internacionalização
cached_network_image: ^3.4.1   # Cache de imagens
url_launcher: ^6.3.1           # Abertura de URLs/WhatsApp
```

## Regras de Código

- ✅ Sem uso de `.withOpacity()` (usa `.withValues(alpha: value)`)
- ✅ Sem comentários no código
- ✅ Arquivos com máximo 200 linhas
- ✅ Métodos com máximo 20 linhas
- ✅ Widgets `const` sempre que possível
- ✅ Factory constructors para models
- ✅ Tratamento de erros com Either/Result pattern

## Personalização de Temas

O sistema aplica automaticamente o tema do tenant:

```dart
ThemeConfig.buildTheme(
  primaryColor: Color.fromHex('#2196F3'),
  secondaryColor: Color.fromHex('#FF9800'),
  fontFamily: 'Roboto',
);
```

## Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

## Licença

Este projeto é privado e proprietário.

## Suporte

Para suporte, entre em contato através do email: suporte@vitrinavirtual.com
# vitrine_virtual
