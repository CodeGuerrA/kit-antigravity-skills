#!/usr/bin/env node
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const { Command } = require('commander');

const program = new Command();

const ASCII_ART = `
   _____          __  .__                               .__  __          ____  __.__  __   
  /  _  \\   _____/  |_|__| ___________  ______ ___  _|__|/  |_ ___.__.|    |/ _|__|/  |_ 
 /  /_\\  \\ /    \\   __\\  |/ ___\\_  __ \\/  __  \\\\  \\/ /  \\   __<   |  ||      < |  \\   __\\
/    |    \\   |  \\  | |  / /_/  >  | \\/\\  /_/  />    <|  ||  |  \\___  ||    |  \\|  ||  |  
\\____|__  /___|  /__| |__\\___  /|__|    \\____/ /__/\\_ \\__||__|  / ____||____|__ \\__||__|  
        \\/     \\/       /_____/                      \\/         \\/             \\/         
`;

program
  .name('antigravity-kit')
  .description('Engine de templates de IA para agentes especializados e Quality Gate.')
  .version('1.0.0');

program
  .command('init')
  .description('Instala as regras do Antigravity Kit no projeto atual.')
  .option('-f, --force', 'Sobrescreve configurações existentes (.agent e GEMINI.md)')
  .action(async (options) => {
    console.log(chalk.cyan(ASCII_ART));
    console.log(chalk.blue('🚀 Inicializando Antigravity Kit...'));

    const templateAgentDir = path.join(__dirname, '../templates/.agent');
    const templateGeminiFile = path.join(__dirname, '../templates/GEMINI.md');
    
    const targetAgentDir = path.join(process.cwd(), '.agent');
    const targetGeminiFile = path.join(process.cwd(), 'GEMINI.md');

    try {
      // 1. Verificar se já existe e se --force foi passado
      if (fs.existsSync(targetAgentDir) && !options.force) {
        console.log(chalk.yellow('⚠️  A pasta .agent já existe. Use --force para sobrescrever.'));
        process.exit(1);
      }

      // 2. Copiar Pasta .agent
      console.log(chalk.white('   📦 Copiando templates de agentes...'));
      await fs.copy(templateAgentDir, targetAgentDir);

      // 3. Copiar GEMINI.md Mestre (Se existir em templates)
      if (fs.existsSync(templateGeminiFile)) {
        console.log(chalk.white('   📝 Configurando GEMINI.md mestre...'));
        await fs.copy(templateGeminiFile, targetGeminiFile);
      } else {
        // Criar um GEMINI.md básico se o template não existir
        console.log(chalk.gray('   ℹ️  Template GEMINI.md não encontrado. Criando arquivo base...'));
        const basicGemini = `# PROJETO: ${path.basename(process.cwd())}\n\n---\n\nEste projeto utiliza o **Antigravity Kit**. As regras de Quality Gate e especialistas estão em \`.agent/\`.`;
        await fs.writeFile(targetGeminiFile, basicGemini);
      }

      console.log('\n' + chalk.green('✅ Antigravity Kit instalado com sucesso!'));
      console.log(chalk.cyan('\nPróximos passos:'));
      console.log(chalk.white('  1. Configure seu projeto no arquivo ') + chalk.bold('GEMINI.md'));
      console.log(chalk.white('  2. Explore os especialistas em ') + chalk.bold('.agent/agents/'));
      console.log(chalk.white('  3. Ative o Gemini CLI ou Cursor para ler o novo contexto.'));
      
    } catch (err) {
      console.error(chalk.red('\n❌ Erro durante a instalação:'), err);
      process.exit(1);
    }
  });

program.parse(process.argv);
