const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('Starting master production build...');

// 1. Build the React application
console.log('Building React web application...');
execSync('npm run build -w apps/web', { stdio: 'inherit' });

// 2. Create the master production output folder 'dist'
const distDir = path.join(__dirname, 'dist');
if (fs.existsSync(distDir)) {
  fs.rmSync(distDir, { recursive: true, force: true });
}
fs.mkdirSync(distDir);

// 3. Copy landing page assets to the root of 'dist'
console.log('Copying landing page assets...');
const landingDir = path.join(__dirname, 'apps', 'landing');
copyFolderRecursiveSync(landingDir, distDir);

// 4. Create the 'app' subfolder inside 'dist'
const appDistDir = path.join(distDir, 'app');
if (!fs.existsSync(appDistDir)) {
  fs.mkdirSync(appDistDir);
}

// 5. Copy built React app assets to 'dist/app'
console.log('Copying React webapp build output to /app...');
const webBuildDir = path.join(__dirname, 'apps', 'web', 'dist');
copyFolderRecursiveSync(webBuildDir, appDistDir);

console.log('Build completed successfully!');

// Helper function to copy directories recursively
function copyFolderRecursiveSync(source, target) {
  let files = [];

  // Check if folder needs to be created
  const targetFolder = target;
  if (!fs.existsSync(targetFolder)) {
    fs.mkdirSync(targetFolder);
  }

  // Copy
  if (fs.lstatSync(source).isDirectory()) {
    files = fs.readdirSync(source);
    files.forEach(function (file) {
      const curSource = path.join(source, file);
      const curTarget = path.join(targetFolder, file);
      if (fs.lstatSync(curSource).isDirectory()) {
        copyFolderRecursiveSync(curSource, curTarget);
      } else {
        fs.copyFileSync(curSource, curTarget);
      }
    });
  }
}
