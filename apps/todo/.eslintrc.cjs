module.exports = {
  root: true,
  env: {
    es2022: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  plugins: ['@typescript-eslint', 'react-hooks', 'react-refresh'],
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended', 'plugin:react-hooks/recommended', 'prettier'],
  ignorePatterns: ['**/dist/**', '**/node_modules/**'],
  overrides: [
    {
      files: ['frontend/**/*.{ts,tsx}'],
      env: {
        browser: true,
      },
      rules: {
        'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
      },
    },
    {
      files: ['backend/**/*.ts', 'shared/**/*.ts'],
      env: {
        node: true,
      },
    },
  ],
};
