package ${packageName}.model;
 
import com.google.gson.Gson;
import com.google.gson.TypeAdapterFactory;
import com.google.gson.TypeAdapter;
import com.google.gson.reflect.TypeToken;
import java.lang.SuppressWarnings;
 
public final class ModelAdapterFactory {
    public static TypeAdapterFactory create() {
        return new TypeAdapterFactory() {
            @SuppressWarnings("unchecked")
            public <T> TypeAdapter<T> create(Gson gson, TypeToken<T> type) {
                Class<T> rawType = (Class<T>) type.getRawType();
 
                if (${packageName}.model.${gsonModels[0].package}.${gsonModels[0].name}.class.isAssignableFrom(rawType)) {
                    return (TypeAdapter<T>) new ${packageName}.model.${gsonModels[0].package}.${gsonModels[0].name}.GsonTypeAdapter(gson);
<#list gsonModels[2..] as model>
                } else if (${packageName}.model.${model.package}.${model.name}.class.isAssignableFrom(rawType)) {
                    return (TypeAdapter<T>) new ${packageName}.model.${model.package}.${model.name}.GsonTypeAdapter(gson);
</#list>
                } else {
                    return null;
                }
            }
        };
    }
}