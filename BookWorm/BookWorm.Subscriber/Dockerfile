FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["BookWorm.Subscriber/BookWorm.Subscriber.csproj", "BookWorm.Subscriber/"]
COPY ["BookWorm.Model/BookWorm.Model.csproj", "BookWorm.Model/"]
RUN dotnet restore "BookWorm.Subscriber/BookWorm.Subscriber.csproj"
COPY . .
WORKDIR "/src/BookWorm.Subscriber"
RUN dotnet build "BookWorm.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BookWorm.Subscriber.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY BookWorm.Subscriber/appsettings.json .
ENTRYPOINT ["dotnet", "BookWorm.Subscriber.dll"]
