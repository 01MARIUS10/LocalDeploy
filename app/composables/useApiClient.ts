import { ApiClient } from "~/frontend/apiClient";

const apiClient = new ApiClient();

export const useApiClient = () => {
  return apiClient;
};
