let isShuttingDown = false;

export const markShuttingDown = () => {
  isShuttingDown = true;
};

export const getIsShuttingDown = () => isShuttingDown;
